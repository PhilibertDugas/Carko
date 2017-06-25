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
import Crashlytics
import MapKit

class EventsCollectionViewController: UICollectionViewController {
    fileprivate let reservationIdentifier = "ReservationCell"
    fileprivate let reuseIdentifier = "EventCell"
    fileprivate var events = [Event?](repeating: Event.init(), count: 5)
    fileprivate var reservations: [(Reservation?)] = []

    fileprivate var selectedEvent: Event!
    fileprivate var refresher: UIRefreshControl!
    fileprivate var revealViewController: SWRevealViewController!
    fileprivate var loadedOnce = false

    fileprivate var bluredView: UIView!
    fileprivate var mapView: MKMapView!
    fileprivate var mainScreenShadow: UIView!

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
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTriggered), name: Notification.Name.init(rawValue: "LoggedOut"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.prepareBackgroundView()

        self.mainScreenShadow = UIView.init(frame: self.view.frame)
        self.mainScreenShadow.backgroundColor = UIColor.black
        self.mainScreenShadow.isHidden = true
        self.view.superview?.insertSubview(mainScreenShadow, aboveSubview: self.view)

        if !self.loadedOnce {
            Loader.addLoaderTo(self.collectionView!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        self.refreshTriggered()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.secondaryViewsBlack
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
            self.mapView.frame = collectionView.bounds
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
                Crashlytics.sharedInstance().recordError(error)
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.reservations = reservations
                ReservationManager.shared.cacheReservations(reservations: reservations)
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
        } else {
            self.reservations = []
        }
    }

    fileprivate func prepareBackgroundView() {
        if self.bluredView != nil {
            self.bluredView.removeFromSuperview()
            self.mapView.removeFromSuperview()
        }

        self.bluredView = UIView.init()
        self.bluredView.backgroundColor = UIColor.black
        self.bluredView.alpha = 0.8
        self.bluredView.frame = UIScreen.main.bounds
        self.mapView = MKMapView.init(frame: self.bluredView.frame)
        let center = CLLocationCoordinate2D.init(latitude: 45.502, longitude: -73.572)
        let region = MKCoordinateRegionMakeWithDistance(center, CLLocationDistance(700), CLLocationDistance(700))
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
        self.collectionView?.insertSubview(mapView, at: 0)
        self.collectionView?.insertSubview(bluredView, aboveSubview: mapView)
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

    func revealController(_ revealController: SWRevealViewController!, animateTo position: FrontViewPosition) {
        if position == .left {
            self.mainScreenShadow.isHidden = true
            self.mainScreenShadow.alpha = 0
        } else if position == .right {
            self.mainScreenShadow.isHidden = false
            self.mainScreenShadow.alpha = 0.8
        }
    }

    func revealController(_ revealController: SWRevealViewController!, panGestureMovedToLocation location: CGFloat, progress: CGFloat) {
        if progress > 1 {
            self.mainScreenShadow.isHidden = false
            self.mainScreenShadow.alpha = 0.8
        } else if progress == 0 {
            self.mainScreenShadow.isHidden = true
            self.mainScreenShadow.alpha = 0
        } else {
            self.mainScreenShadow.isHidden = false
            self.mainScreenShadow.alpha = 0.8 * progress
        }
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
        if let url = event?.photoURL {
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
