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
        self.setupPullToRefresh()
        self.setupSidebar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTriggered), name: Notification.Name.init(rawValue: "LoggedOut"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTriggered), name: Notification.Name.init(rawValue: "LoggedIn"), object: nil)

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

                if AuthenticationHelper.customerAvailable() {
                    self.fetchReservations()
                } else {
                    self.reservations = []
                    self.refresher.endRefreshing()
                    self.collectionView?.reloadData()
                }
            }
        }
    }

    private func fetchReservations() {
        Reservation.getCustomerActiveReservations { (reservations, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.removeDuplicatedEvents(reservations)
                self.reservations = reservations
            }
            self.refresher.endRefreshing()
            self.collectionView?.reloadData()
        }
    }

    // TODO: Extract out of the ViewController
    private func removeDuplicatedEvents(_ reservations: [(Reservation?)]) {
        var indexesToRemove: [Int: Int] = [:]
        for reservation in reservations {
            guard let event = reservation?.event else { continue }
            for (index, e) in self.events.enumerated() {
                if event.id == e?.id {
                    indexesToRemove[event.id] = index
                }
            }
        }

        indexesToRemove.forEach { (_, value) in
            self.events.remove(at: value)
        }
    }

    fileprivate func setupPullToRefresh() {
        self.collectionView?.alwaysBounceVertical = true
        self.refresher = UIRefreshControl.init()
        refresher.addTarget(self, action: #selector(self.refreshTriggered), for: .valueChanged)
        self.collectionView?.addSubview(self.refresher)
    }

    func refreshTriggered() {
        self.fetchEvents()
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
        if self.mapView == nil {
            self.mapView = MKMapView.init(frame: self.bluredView.frame)
        }

        let center = CLLocationCoordinate2D.init(latitude: 45.502, longitude: -73.572)
        let region = MKCoordinateRegionMakeWithDistance(center, CLLocationDistance(700), CLLocationDistance(700))
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
        self.collectionView?.insertSubview(mapView, at: 0)
        self.collectionView?.insertSubview(bluredView, aboveSubview: mapView)
    }
}

extension EventsCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return self.reservations.count
        } else if section == 1 {
            if self.reservations.count == 0 {
                return 1
            } else {
                return 0
            }
        }
        else {
            if self.reservations.count == 0 {
                return self.events.count - 1
            } else {
                return self.events.count
            }
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
        if indexPath.section == 1 {
            cell.event = self.events[0]
        } else {
            if self.reservations.count == 0 {
                cell.event = self.events[indexPath.row + 1]
            } else {
                cell.event = self.events[indexPath.row]
            }
        }
        cell.layer.cornerRadius = 10
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 || indexPath.section == 2 {
            self.selectedEvent = self.events[indexPath.row]
            self.performSegue(withIdentifier: "showEvent", sender: nil)
        }
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
