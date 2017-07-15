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
import GoogleMaps

class FindParkingViewController: UIViewController {
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var navItem: UINavigationItem!

    var gmsMapView: GMSMapView!
    var selectedMarker: GMSMarker?

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

extension FindParkingViewController: MKMapViewDelegate, GMSMapViewDelegate {
    fileprivate func initializeMap() {
        let camera = GMSCameraPosition.camera(withTarget: event.coordinate(), zoom: 13.0)
        
        self.gmsMapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), camera: camera)
        self.gmsMapView.delegate = self

        self.view.insertSubview(self.gmsMapView, belowSubview: self.navBar)
    }

    func parkingFetched(_ parkings: [(Parking?)]) {
        self.gmsMapView.clear()

        self.setupEventPin()
        for parking in parkings {
            guard let parking = parking else { continue }
            if parking.isComplete {
                let marker = ParkingMarker.init(parking: parking, event: event)
                marker.position = parking.coordinate()
                marker.layer.anchorPoint = CGPoint.init(x: 0.5, y: 1.0)
                marker.map = self.gmsMapView
            }
        }
    }

    func setupEventPin() {
        let centerMarker = GMSMarker.init()
        centerMarker.position = event.coordinate()
        centerMarker.map = self.gmsMapView

        let circle = GMSCircle.init(position: event.coordinate(), radius: CLLocationDistance(event.range))
        circle.strokeColor = UIColor.red
        circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
        circle.strokeWidth = 0.1
        circle.map = self.gmsMapView

    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if self.selectedMarker != nil {
            UIView.animate(withDuration: 0.2, animations: { 
                self.bookParkingVC.view.frame = CGRect.init(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            })

            UIView.animate(withDuration: 0.3, animations: {
                self.selectedMarker?.iconView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }

        if let marker = marker as? ParkingMarker {
            self.selectedMarker = marker
            // Make the pin bigger when we select it to indicate a selection
            UIView.animate(withDuration: 0.3, animations: {
                marker.iconView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            })

            self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
            self.bookParkingVC.sheetDelegate = self
            self.bookParkingVC.delegate = self

            let parking = marker.parking
            self.bookParkingVC.parking = parking
            self.bookParkingVC.event = self.event

            self.addChildViewController(self.bookParkingVC)
            self.view.addSubview(self.bookParkingVC.view)
            self.bookParkingVC.didMove(toParentViewController: self)

            let height = self.view.frame.height
            let width = self.view.frame.width
            self.bookParkingVC.view.frame = CGRect.init(x: 0, y: self.view.frame.maxY, width: width, height: height)
        }
        return true
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if self.selectedMarker != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.selectedMarker?.iconView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })

            self.selectedMarker = nil
            UIView.animate(withDuration: 0.5, animations: {
                self.bookParkingVC.view.frame = CGRect.init(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            })
        }
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // Amener la sheet plus basse quand on se deplace sur la map
        guard self.bookParkingVC != nil else { return }
        if self.bookParkingVC.view.frame.origin.y < self.view.frame.height {
            // GMSMapView willMove is already wrapped in an animation, to make the sheet animation smooth we need some gymnastic here
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.bookParkingVC.view.frame = CGRect.init(x: 0, y: self.bookParkingVC.minimalView, width: self.view.frame.width, height: self.view.frame.height)
                    }

                }
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
