//
//  FindParkingViewControllerTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-31.
//  Copyright © 2016 QH4L. All rights reserved.
//

import XCTest
import CoreLocation
import MapKit
@testable import Carko


class FindParkingViewControllerTest: XCTestCase {
    var vc: FindParkingViewController!

    override func setUp() {
        super.setUp()

        // Gymnastic to get the view controller properly intialized
        let storyboard = UIStoryboard.init(name: "FindParking", bundle: Bundle.main)
        vc = storyboard.instantiateInitialViewController() as! FindParkingViewController
        UIApplication.shared.keyWindow?.rootViewController = vc
        let _ = vc.view
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFetchedParkingAppearOnTheMap() {
        vc.parkingFetched(setupTestParking())
        XCTAssertEqual(2, vc.mapView.annotations.count)
        let firstAnnotation = vc.mapView.annotations[0] as! ParkingAnnotation
        let secondAnnotation = vc.mapView.annotations[1] as! ParkingAnnotation
        XCTAssertEqual(1, firstAnnotation.parking.id)
        XCTAssertEqual(2, secondAnnotation.parking.id)
    }

    func testParkingAreGrayWhenNotAvailable() {
        vc.parkingFetched(setupTestParking())
        let firstAnnotation = vc.mapView.annotations[0] as! ParkingAnnotation
        let secondAnnotation = vc.mapView.annotations[1] as! ParkingAnnotation
        XCTAssert(firstAnnotation.parking.isAvailable)
        XCTAssert(!secondAnnotation.parking.isAvailable)
        let firstView = vc.mapView(vc.mapView, viewFor: firstAnnotation) as! MKPinAnnotationView
        let secondView = vc.mapView(vc.mapView, viewFor: secondAnnotation) as! MKPinAnnotationView
        XCTAssertEqual(UIColor.red, firstView.pinTintColor)
        XCTAssertEqual(UIColor.gray, secondView.pinTintColor)
    }
}

extension FindParkingViewControllerTest {
    func setupTestParking() -> [(Parking)] {
        let parking1 = Parking.init(latitude: CLLocationDegrees.init(-74.00),longitude: CLLocationDegrees.init(135.00),photoURL: URL.init(string: "www.test.com")!, address: "1160 Rue Villeray", price: 2.00, pDescription: "Unit Test Parking", isAvailable: true, availabilityInfo: AvailabilityInfo.init(), customerId: 1)
        parking1.id = 1
        let parking2 = Parking.init(latitude: CLLocationDegrees.init(-74.00),longitude: CLLocationDegrees.init(135.00),photoURL: URL.init(string: "www.test.com")!, address: "1160 Rue Villeray", price: 2.00, pDescription: "Unit Test Parking", isAvailable: false, availabilityInfo: AvailabilityInfo.init(), customerId: 2)
        parking2.id = 2
        return [parking1, parking2]
    }
}
