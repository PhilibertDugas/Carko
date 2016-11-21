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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Parking.getAllParkings()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
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
        return nil
    }
}
