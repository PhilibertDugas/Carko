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
import FirebaseStorageUI
import FirebaseAuth
import SCLAlertView

class FindParkingViewController: UIViewController {
    @IBOutlet var popupView: MarkerPopup!
    @IBOutlet var mapView: MKMapView!

    let locationManager = CLLocationManager()

    var tabBar: UITabBar!
    var bookParkingVC: BookParkingViewController!
    var animator: ARNTransitionAnimator!

    var selectedParking: Parking!
    var event: Event!

    @IBAction func annotationTapped(_ sender: Any) {
        self.present(self.bookParkingVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let center = CLLocationCoordinate2D.init(latitude: event.latitude, longitude: event.longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, CLLocationDistance(self.event.range * 2), CLLocationDistance(self.event.range * 2))
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)

        self.prepareAnimation()
        self.setupAnimator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let customer = AppState.shared.cachedCustomer()
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.popupView.isHidden = true
    }

    func setupFirstView() {
        let alreadyViewed = UserDefaults.standard.bool(forKey: "alreadyViewedFind")
        if alreadyViewed == false {
            let responder = SCLAlertView.init().showInfo("How it works", subTitle: "Find any parking spot on the map to see their availability and book them!", colorStyle: 0x00C441, colorTextButton: 0xFFFFFA)
            responder.setDismissBlock {
                UserDefaults.standard.set(true, forKey: "alreadyViewedFind")
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
        fetchParkings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.customer != nil {
            fetchParkings()
        }
    }

    func fetchParkings() {
        Parking.getAllParkings { (parkings, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.parkingFetched(parkings)
            }
        }
    }
}

extension FindParkingViewController {
    func prepareAnimation() {
        if let tabController = self.tabBarController {
            self.tabBar = tabController.tabBar
        } else {
            self.tabBar = UITabBarController.init().tabBar
        }

        self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
        self.bookParkingVC.modalPresentationStyle = .overCurrentContext
        self.bookParkingVC.delegate = self

        self.bookParkingVC.tapCloseButtonActionHandler = { _ in
            self.popupView.descriptionLabel.text = self.selectedParking.address
            self.popupView.frame.origin.y = self.mapView.frame.height - self.tabBar.frame.height
        }
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
        self.animator!.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        self.bookParkingVC.transitioningDelegate = self.animator
    }
}

extension FindParkingViewController: MKMapViewDelegate {
    func parkingFetched(_ parkings: [(Parking)]) {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setupEventPin()
        let now = Date.init()
        for parking in parkings {
            //if parking.isComplete && parking.scheduleAvailable(now) {
            if parking.scheduleAvailable(now) {
                let annotation = ParkingAnnotation.init(parking: parking, event: self.event)
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    func setupEventPin() {
        let centerAnnotation = MKPointAnnotation.init()
        centerAnnotation.coordinate = self.event.coordinate()
        let circle = MKCircle.init(center: self.event.coordinate(), radius: Double(self.event.range) as CLLocationDistance)
        self.mapView.addAnnotation(centerAnnotation)
        self.mapView.add(circle)

    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? ParkingAnnotation {
            let parking = annotation.parking
            self.selectedParking = parking
            self.bookParkingVC.parking = parking
            self.bookParkingVC.event = self.event

            popupView.descriptionLabel.text = parking.address
            popupView.priceLabel.text = event.price.asLocaleCurrency

            if let url = parking.photoURL {
                let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
                popupView.imageView.sd_setImage(with: imageReference)
            }

            UIView.animate(withDuration: 0.15, animations: { 
                self.popupView.isHidden = false
                self.popupView.backgroundColor = UIColor.white
                let yOrigin = self.mapView.frame.height - self.tabBar.frame.height
                self.popupView.frame.origin.y = yOrigin
            })
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.15, animations: {
            self.popupView.frame.origin.y = self.view.frame.maxY
            self.popupView.isHidden = true
        })
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingAnnotation {
            let annotationView = ParkingAnnotationView.init(annotation: annotation, reuseIdentifier: nil)
            return annotationView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let av = self.mapView.view(for: self.mapView.userLocation)
        av?.isEnabled = false
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer.init(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 0.1
            return circle
        } else {
            return MKOverlayRenderer.init()
        }
    }
}

extension FindParkingViewController: ReservationDelegate {
    func reservationCompleted() {
        self.fetchParkings()
    }
}
