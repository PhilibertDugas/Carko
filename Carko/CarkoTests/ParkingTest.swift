//
//  ParkingTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-26.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Carko

class ParkingTest: XCTestCase {
    var parkingDict: [String: Any]!

    override func setUp() {
        super.setUp()
        parkingDict = [
            "latitude": CLLocationDegrees.init(1),
            "longitude": CLLocationDegrees.init(1),
            "address": "Testtt",
            "description": "Huehue",
            "is_available": true,
            "customer_id": 1,
            "is_complete": true,
            "availability_info": [
                "start_time": "00:00",
                "stop_time": "23:59",
                "days_available": [0, 0, 0, 0, 0, 0, 0],
                "always_available": true
            ],
            "multiple_photo_urls": ["https://google.com"]
        ]
    }

    func testInitParkingReturnsWhenMissingData() {
        let partialParking: [String: Any] = ["address": "test"]
        XCTAssertNil(Parking.init(parking: partialParking))
    }

    func testInitParkingReturnsNilWhenFieldsHaveInvalidTypes() {
        parkingDict["is_available"] = "Lol this should be boolean"
        XCTAssertNil(Parking.init(parking: parkingDict))
    }

    func testInitParkingReturnsAParkingWhenFieldsAreValid() {
        XCTAssertNotNil(Parking.init(parking: parkingDict))
    }

    func testOptionalFieldsAreAddedWhenValid() {
        parkingDict["photo_url"] = "https://google.com"
        parkingDict["id"] = 1
        parkingDict["total_revenue"] = Float(10.0)
        let parking = Parking.init(parking: parkingDict)
        XCTAssertNotNil(parking)
        XCTAssertEqual(URL.init(string: "https://google.com"), parking?.photoURL)
        XCTAssertEqual(1, parking?.id)
        XCTAssertEqual(Float(10.0), parking?.totalRevenue)
    }

    func testOptionalFieldsAreNotAddedWhenInvalid() {
        parkingDict["photo_url"] = 1
        parkingDict["id"] = "Breaking"
        parkingDict["total_revenue"] = "Chaos"
        let parking = Parking.init(parking: parkingDict)
        XCTAssertNotNil(parking)
        XCTAssertNil(parking?.photoURL)
        XCTAssertNil(parking?.id)
        XCTAssertEqual(0.0, parking?.totalRevenue)
    }
}
