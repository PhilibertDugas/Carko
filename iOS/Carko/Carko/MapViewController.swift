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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            } else {
                let newCam = GMSCameraUpdate.setTarget(currentCoordinate)
                mapView.animate(with: newCam)
            }
            
            // Creates a marker in the center of the map.
            /*
             let marker = GMSMarker()
             marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
             marker.title = "Sydney"
             marker.snippet = "Australia"
             marker.map = mapView
             */
        }
    }
}
