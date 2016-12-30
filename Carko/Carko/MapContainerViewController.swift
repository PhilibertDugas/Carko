//
//  MapContainerViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import MapKit

class MapContainerViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    var firstZoom = true
    let locationManager = CLLocationManager()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Parking.getAllParkings()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self

        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView.init(effect: effect)
        blurView.frame = CGRect.init(x: 0.0, y: 0.0, width: view.bounds.width, height: 20.0)
        mapView.addSubview(blurView)


        locationManager.requestWhenInUseAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(MapContainerViewController.parkingFetched), name: Notification.Name.init(rawValue: "ParkingFetched"), object: nil)
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

extension MapContainerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if firstZoom {
            firstZoom = false
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? ParkingAnnotation {
            let parking = annotation.parking
            let data = ["data" : parking]
            NotificationCenter.default.post(name: Notification.Name.init("ParkingSelected"), object: nil, userInfo: data)
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        NotificationCenter.default.post(name: Notification.Name.init("ParkingDeselected"), object: nil, userInfo: nil)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingAnnotation {
            let annotationView = MKPinAnnotationView.init()
            if annotation.parking.isAvailable {
                annotationView.pinTintColor = UIColor.red
            } else {
                annotationView.pinTintColor = UIColor.gray
            }
            return annotationView
        }
        return nil
    }
}
