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

class FindParkingViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navItem: UINavigationItem!

    let locationManager = CLLocationManager()
    var event: Event!

    var bookParkingVC: BookParkingViewController!
    var sheetAppeared: Bool = false

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navItem.titleView = UIImageView.init(image: UIImage.init(named: "white_logo"))
        self.initializeMap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sheetAppeared = false
        self.locationManager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear

        let reveal = self.revealViewController
        reveal().panGestureRecognizer().isEnabled = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.fetchParkings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        let reveal = self.revealViewController
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.secondaryViewsBlack

        reveal().panGestureRecognizer().isEnabled = true
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

    func parkingFetched(_ parkings: [(Parking?)]) {
        self.mapView.removeAnnotations(mapView.annotations)
        self.setupEventPin()
        for parking in parkings {
            guard let parking = parking else { continue }
            if parking.isComplete {
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
            // Make the pin bigger when we select it to indicate a selection
            UIView.animate(withDuration: 0.5) {
                view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
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
        if view.annotation is ParkingAnnotation {
            UIView.animate(withDuration: 0.5, animations: {
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.bookParkingVC.view.frame = CGRect.init(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            })
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingAnnotation {
            let annotationView = ParkingAnnotationView.init(annotation: annotation, reuseIdentifier: nil)
            // the bottom of the pin is the anchor, it shouldnt move when scaling
            annotationView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 1.0)
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

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // Amener la sheet plus basse quand on se deplace sur la map
        guard let bottomSheet = self.bookParkingVC else { return }
        if bottomSheet.view.frame.origin.y < self.view.frame.height {
            UIView.animate(withDuration: 0.5) {
                bottomSheet.view.frame = CGRect.init(x: 0, y: bottomSheet.minimalView, width: self.view.frame.width, height: self.view.frame.height)
            }

        }
    }
}

extension FindParkingViewController: ReservationDelegate {
    func reservationCompleted() {
        self.navigationController?.popToRootViewController(animated: true)
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
