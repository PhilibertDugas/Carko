//
//  EventTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-23.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Carko

class EventTest: XCTestCase {
    var eventDict: [String: Any]!
    override func setUp() {
        super.setUp()
        eventDict = [
            "id": 1,
            "latitude": CLLocationDegrees.init(1),
            "longitude": CLLocationDegrees.init(1),
            "photo_url": "https://google.com",
            "range": 500,
            "price": Float(10.0),
            "label": "Testing",
            "target_audience": 100,
            "start_time": "2017-03-17T00:00:00Z000",
            "end_time": "2017-03-18T00:00:00Z000"
        ]
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testInitEventReturnsNilWhenMissingData() {
        let partialEvent: [String: Any] = ["id": 1]
        XCTAssertNil(Event.init(event: partialEvent))
    }

    func testInitEventReturnsNilWhenFieldsHaveInvalidTypes() {
        eventDict["id"] = "Lol this should be an integer"
        XCTAssertNil(Event.init(event: eventDict))
    }

    func testInitEventReturnsAnEventWhenFieldsAreValid() {
        XCTAssertNotNil(Event.init(event: eventDict))
    }
}
