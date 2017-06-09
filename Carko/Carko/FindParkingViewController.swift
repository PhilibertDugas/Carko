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
    @IBOutlet var navigationImageView: UIImageView!

    let locationManager = CLLocationManager()
    var bluredView: UIVisualEffectView!
    var bookParkingVC: BookParkingViewController!
    var event: Event!

    var sheetAppeared: Bool = false

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView.init(image: UIImage.init(named: "white_logo"))
        self.navigationImageView.frame = (self.navigationItem.titleView?.bounds)!
        self.initializeMap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sheetAppeared = false
        self.locationManager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.fetchParkings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }

    func fetchParkings() {
        self.event.getParkings { (parkings, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.parkingFetched(parkings)
            }
        }
    }
}

extension FindParkingViewController: MKMapViewDelegate {
    fileprivate func initializeMap() {
        self.mapView.delegate = self
        let center = CLLocationCoordinate2D.init(latitude: event.latitude, longitude: event.longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, CLLocationDistance(self.event.range * 2), CLLocationDistance(self.event.range * 2))
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
    }

    func parkingFetched(_ parkings: [(Parking)]) {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setupEventPin()
        for parking in parkings {
            // FIXME
            //if parking.isComplete && parking.scheduleAvailable(now) {
            let annotation = ParkingAnnotation.init(parking: parking, event: self.event)
            self.mapView.addAnnotation(annotation)
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
            self.bookParkingVC.delegate = self

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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.fetchParkings()
    }
}

extension FindParkingViewController: MapSheetDelegate {
    func didAppear() {
        if !self.sheetAppeared {
            self.view.frame = CGRect.init(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height)
            self.view.layer.cornerRadius = 10
            self.view.clipsToBounds = true
            self.sheetAppeared = true
        }
    }

    func didDisappear() {
        if self.sheetAppeared {
            self.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.layer.cornerRadius = 0
            self.view.clipsToBounds = false
            self.sheetAppeared = false
        }
    }
}
