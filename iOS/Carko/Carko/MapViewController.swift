//
//  MapViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-03.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import ARNTransitionAnimator

class MapViewController: UIViewController {

    var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    var selectedParking: Parking?

    var tabBar: UITabBar!
    var bookParkingVC: BookParkingViewController!
    @IBOutlet var popupView: MarkerPopup!
    var animator: ARNTransitionAnimator!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Parking.getAllParkings()

        print("MapViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("MapViewController viewWillDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar = self.tabBarController?.tabBar

        popupView.isHidden = true
        self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
        self.bookParkingVC.modalPresentationStyle = .overFullScreen
        self.setupAnimator()
        
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func setupAnimator() {
        let animation = ParkingTransitionAnimation(rootVC: self, modalVC: self.bookParkingVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(_self.bookParkingVC.view)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }

        let gestureHandler = TransitionGestureHandler(targetVC: self, direction: .top)
        gestureHandler.registerGesture(self.popupView)
        gestureHandler.panCompletionThreshold = 15.0

        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)

        self.bookParkingVC.transitioningDelegate = self.animator
    }
    
    func parkingFetched(_ notification: Notification) {
        if let parkingData = notification.userInfo as? [String: Any] {
            mapView.clear()

            let parkings = parkingData["data"] as! [(Parking)]

            for parking in parkings {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D.init(latitude: parking.latitude, longitude: parking.longitude)
                marker.userData = parking
                marker.title = parking.address
                marker.map = mapView
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentCoordinate = manager.location?.coordinate {
            if mapView == nil {
                let camera = GMSCameraPosition.camera(withLatitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude, zoom: 15.0)
                mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
                mapView.isMyLocationEnabled = true
                mapView.delegate = self
                view.insertSubview(mapView, at: 0)
                NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.parkingFetched), name: Notification.Name.init(rawValue: "ParkingFetched"), object: nil)
            } else {
                let newCam = GMSCameraUpdate.setTarget(currentCoordinate)
                mapView.animate(with: newCam)
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.selectedParking = marker.userData as? Parking
        self.bookParkingVC.parking = self.selectedParking
        popupView.descriptionLabel.text = self.selectedParking?.address
        popupView.isHidden = false
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(MapViewController.markerTapped))
        popupView.addGestureRecognizer(tapGesture)

        return true
    }

    func markerTapped(recognizer: UITapGestureRecognizer) {
        self.present(self.bookParkingVC, animated: true, completion: nil)
    }
}
