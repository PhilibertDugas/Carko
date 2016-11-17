//
//  FindParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import ARNTransitionAnimator
import MapKit

class FindParkingViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var selectedParking: Parking?

    var tabBar: UITabBar!
    var bookParkingVC: BookParkingViewController!
    @IBOutlet var popupView: MarkerPopup!
    var animator: ARNTransitionAnimator!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("FindParkingViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("FindParkingViewController viewWillDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Parking.getAllParkings()

        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(FindParkingViewController.parkingFetched), name: Notification.Name.init(rawValue: "ParkingFetched"), object: nil)

        self.tabBar = self.tabBarController?.tabBar

        popupView.isHidden = true
        self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
        self.bookParkingVC.modalPresentationStyle = .overFullScreen
        self.setupAnimator()
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
            self.mapView.removeAnnotations(mapView.annotations)

            let parkings = parkingData["data"] as! [(Parking)]

            for parking in parkings {
                let annotation = ParkingAnnotation.init(parking: parking)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension FindParkingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
        self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? ParkingAnnotation {
            self.selectedParking = annotation.parking
            self.bookParkingVC.parking = self.selectedParking
            popupView.descriptionLabel.text = self.selectedParking?.address
            popupView.isHidden = false
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(FindParkingViewController.annotationTapped))
            popupView.addGestureRecognizer(tapGesture)
        }
    }

    func annotationTapped() {
        self.present(self.bookParkingVC, animated: true, completion: nil)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        popupView.isHidden = true
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
}


