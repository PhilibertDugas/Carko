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
    fileprivate let reservationIdentifier = "ReservationCell"
    fileprivate let reuseIdentifier = "EventCell"
    fileprivate var events = [Event](repeating: Event.init(), count: 5)
    fileprivate var reservations: [(Reservation)] = []

    fileprivate var selectedEvent: Event!
    fileprivate var refresher: UIRefreshControl!
    fileprivate var revealViewController: SWRevealViewController!
    fileprivate var loadedOnce = false

    fileprivate var bluredView: UIVisualEffectView!


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

    override func viewDidAppear(_ animated: Bool) {
        self.prepareBackgroundView()
        if !self.loadedOnce {
            Loader.addLoaderTo(self.collectionView!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshTriggered()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEvent" {
            let vc = segue.destination as! FindParkingViewController
            vc.event = self.selectedEvent
        }
    }

    override func viewDidLayoutSubviews() {
        if let bluredView = self.bluredView, let collectionView = self.collectionView {
            bluredView.frame = collectionView.bounds
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
                self.collectionView!.reloadData()
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
        if AuthenticationHelper.customerAvailable() {
            self.fetchReservations()
        }
    }

    fileprivate func prepareBackgroundView() {
        if self.bluredView != nil {
            self.bluredView.removeFromSuperview()
        }

        let blurEffect = UIBlurEffect.init(style: .dark)
        let vibrancyEffect = UIVibrancyEffect.init(blurEffect: UIBlurEffect.init(style: .light))
        let visualEffect = UIVisualEffectView.init(effect: vibrancyEffect)
        self.bluredView = UIVisualEffectView.init(effect: blurEffect)
        self.bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        self.bluredView.frame = UIScreen.main.bounds
        self.collectionView?.insertSubview(bluredView, at: 0)
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
        revealViewController?.rearViewRevealWidth = 0.8 * UIScreen.main.bounds.width

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
            cell.layer.cornerRadius = 10
            return cell
        } else {
            return setupEventCell(collectionView, cellForItemAt: indexPath)
        }
    }

    fileprivate func setupEventCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.event = self.events[indexPath.row]
        cell.layer.cornerRadius = 10

        // Placeholder cells which don't have a photoURL shouldn't be touched / interacted with
        if cell.event?.photoURL == nil {
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.selectedEvent = self.events[indexPath.row]
            self.performSegue(withIdentifier: "showEvent", sender: nil)
        }
    }
}

extension EventsCollectionViewController: ApyaLayoutDelegate {
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let event = self.events[indexPath.item]
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
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
}
