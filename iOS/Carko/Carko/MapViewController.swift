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

class MapViewController: UIViewController {

    var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidAppear(_ animated: Bool) {
        Parking.getAllParkings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func parkingFetched(_ notification: Notification) {
        if let parkingData = notification.userInfo as? [String: Any] {
            mapView.clear()
            
            for (_, parkingInstance) in parkingData {
                let parking = Parking.init(parking: parkingInstance as! [String : Any])
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D.init(latitude: parking.latitude, longitude: parking.longitude)
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
                mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
                mapView.isMyLocationEnabled = true
                view = mapView
                NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.parkingFetched), name: NSNotification.Name(rawValue: "parkingFetched"), object: nil)
            } else {
                let newCam = GMSCameraUpdate.setTarget(currentCoordinate)
                mapView.animate(with: newCam)
            }
        }
    }
}
