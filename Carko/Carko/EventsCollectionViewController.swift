//
//  EventsCollectionViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-19.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import FirebaseAuth
import AVFoundation


class EventsCollectionViewController: UICollectionViewController {
    private var isHamburgerMenuOpen = false

    fileprivate let reservationIdentifier = "ReservationCell"
    fileprivate let reuseIdentifier = "EventCell"
    fileprivate var events: [(Event)] = [Event.init(), Event.init(), Event.init(), Event.init()]
    fileprivate var reservations: [(Reservation)] = []

    fileprivate var selectedEvent: Event!
    fileprivate var refresher: UIRefreshControl!
    fileprivate var revealViewController: SWRevealViewController!
    fileprivate var loadedOnce = false


    @IBAction func navigationMenuPressed(_ sender: Any) {
        revealViewController.revealToggle(sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView.init(image: UIImage.init(named: "white_logo"))
        if let layout = collectionView?.collectionViewLayout as? ApyaLayout {
            layout.delegate = self
        }
        self.setupPullToRefresh()
        self.setupSidebar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.customer != nil {
            userAuthenticated()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if !self.loadedOnce {
            Loader.addLoaderTo(self.collectionView!)
        }

        let customer = AppState.shared.cachedCustomer()
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
        } else if AppState.shared.customer == nil {
            AppState.shared.cacheCustomer(Customer.init(customer: customer!))
            self.userAuthenticated()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoginScreen" {
            let vc = segue.destination as! UINavigationController
            let entryVc = vc.viewControllers.first as! EntryViewController
            entryVc.delegate = self
        } else if segue.identifier == "showEvent" {
            let vc = segue.destination as! FindParkingViewController
            vc.event = self.selectedEvent
        }
    }

    fileprivate func fetchEvents() {
        self.refresher.beginRefreshing()
        Event.getAllEvents { (events, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.events = events
                if !self.loadedOnce {
                    self.loadedOnce = true
                    Loader.removeLoaderFrom(self.collectionView!)
                }
                self.collectionView?.reloadData()
            }
            self.refresher.endRefreshing()
        }
    }

    fileprivate func fetchReservations() {
        Reservation.getCustomerActiveReservations { (reservations, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.reservations = reservations
                self.collectionView?.reloadData()
            }
        }
    }

    fileprivate func setupPullToRefresh() {
        self.collectionView!.alwaysBounceVertical = true
        self.refresher = UIRefreshControl.init()
        refresher.addTarget(self, action: #selector(EventsCollectionViewController.refreshTriggered), for: .valueChanged)
        self.collectionView?.addSubview(self.refresher)
    }

    func refreshTriggered() {
        self.fetchEvents()
        self.fetchReservations()
    }
}

extension EventsCollectionViewController: SWRevealViewControllerDelegate {
    fileprivate func setupSidebar() {
        revealViewController = self.revealViewController()

        revealViewController?.delegate = self

        revealViewController?.bounceBackOnOverdraw = true
        revealViewController?.stableDragOnOverdraw = false
        revealViewController?.toggleAnimationType = .spring
        revealViewController?.rearViewRevealDisplacement = 44
        revealViewController?.rearViewRevealOverdraw = 10
        revealViewController?.rearViewRevealWidth = 300

        let _ = revealViewController?.panGestureRecognizer()
        let _ = revealViewController?.tapGestureRecognizer()
    }
}

extension EventsCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return self.reservations.count
        } else {
            return self.events.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reservationIdentifier, for: indexPath) as! ReservationCollectionViewCell
            cell.reservation = self.reservations[indexPath.row]
            cell.layer.cornerRadius = 3
            cell.layer.borderWidth = 0.5
            return cell
        } else {
            return setupEventCell(collectionView, cellForItemAt: indexPath)
        }
    }

    fileprivate func setupEventCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.event = self.events[indexPath.row]
        cell.layer.cornerRadius = 3
        cell.layer.borderWidth = 0.5

        // Placeholder cells which don't have a photoURL shouldn't be touched / interacted with
        if cell.event?.photoURL == nil {
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedEvent = self.events[indexPath.row]
        self.performSegue(withIdentifier: "showEvent", sender: nil)
    }
}

extension EventsCollectionViewController: AuthenticatedDelegate {
    func userAuthenticated() {
        let currentUser = FIRAuth.auth()?.currentUser
        currentUser?.getTokenForcingRefresh(true, completion: { (idToken, error) in
            if let error = error {
                print("\(error.localizedDescription)")
                self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
            } else if let token = idToken {
                AppState.shared.authToken = token
                self.refreshTriggered()
            }
        })
    }
}

extension EventsCollectionViewController: ApyaLayoutDelegate {
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let event = self.events[indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        if let url = event.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            let imageView = UIImageView.init()
            imageView.sd_setImage(with: imageReference, placeholderImage: UIImage.init(named: "placeholder-1"), completion: { (image, error, cache, reference) in
                UIView.animate(withDuration: 0.3, animations: { 
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                })
            })
            let rect = AVMakeRect(aspectRatio: imageView.image!.size, insideRect: boundingRect)
            return rect.size.height
        } else {
            let image = UIImage.init(named: "placeholder-1")
            return (image?.size.height)!
        }
    }

    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(4)
        let annotationHeaderHeight = CGFloat(17)
        let event = events[indexPath.item]
        let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        let commentHeight = event.heightForLabel(font: font, width: width)
        let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
        return height
    }

}
