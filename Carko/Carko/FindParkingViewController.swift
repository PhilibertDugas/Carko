//
//  FindParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import MapKit
import FirebaseStorageUI
import FirebaseAuth
import SCLAlertView

class FindParkingViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var bookParkingVC: BookParkingViewController!
    var event: Event!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let center = CLLocationCoordinate2D.init(latitude: event.latitude, longitude: event.longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, CLLocationDistance(self.event.range * 2), CLLocationDistance(self.event.range * 2))
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let customer = AppState.shared.cachedCustomer()
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.customer != nil {
            fetchParkings()
        }
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

extension FindParkingViewController: MKMapViewDelegate {
    func parkingFetched(_ parkings: [(Parking)]) {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setupEventPin()
        let now = Date.init()
        for parking in parkings {
            // FIXME
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
            self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
            self.bookParkingVC.sheetDelegate = self
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            let parking = annotation.parking
            self.bookParkingVC.parking = parking
            self.bookParkingVC.event = self.event

            self.addChildViewController(self.bookParkingVC)
            self.view.addSubview(self.bookParkingVC.view)
            self.bookParkingVC.didMove(toParentViewController: self)
            let height = self.view.frame.height
            let width = self.view.frame.width
            self.bookParkingVC.view.frame = CGRect.init(x: 0, y: self.view.frame.maxY, width: width, height: height)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.bookParkingVC.view.removeFromSuperview()
        self.bookParkingVC.removeFromParentViewController()
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

extension FindParkingViewController: MapSheetDelegate {
    func didAppear() {
        self.mapView.frame = CGRect.init(x: 8, y: 0, width: self.view.frame.width - 16, height: self.view.frame.height)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }

    func didDisappear() {
        self.mapView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        view.layer.cornerRadius = 0
        view.clipsToBounds = false

    }
}
