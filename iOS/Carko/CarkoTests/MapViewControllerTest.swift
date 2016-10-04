//
//  MapControllerTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-02.
//  Copyright © 2016 QH4L. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Carko

class MapViewControllerTest: XCTestCase {
    
    var mapController: MapViewController!
    var locationStartedUpdating = false
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        mapController = storyboard.instantiateViewController(withIdentifier: "mapController") as! MapViewController
        UIApplication.shared.keyWindow!.rootViewController = mapController
        
        let _ = mapController.view
        mapController.locationManager.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

extension MapViewControllerTest: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationStartedUpdating = true
    }
}
