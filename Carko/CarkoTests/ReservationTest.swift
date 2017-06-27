//
//  ReservationTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-23.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest

@testable import Carko

class ReservationTest: XCTestCase {
    var reservationDict: [String: Any]!
    override func setUp() {
        super.setUp()
        reservationDict = [
            "id": 1,
            "parking": Parking.init().toDictionary(),
            "customer_id": 1,
            "is_active": false,
            "start_time": "2017-03-17T00:00:00Z000",
            "stop_time": "2017-03-18T00:00:00Z000",
            "total_cost": Float(10.0),
            "charge": "ch_1234",
            "event": Event.init().toDictionary()
        ]
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitReservationReturnsNilWhenMissingData() {
        let partialReservation: [String: Any] = ["parking": Parking.init().toDictionary(), "customer_id": 1, "is_active": false]
        XCTAssertNil(Reservation.init(reservation: partialReservation))
    }

    func testInitReservationReturnsNilWhenFieldsHaveInvalidTypes() {
        reservationDict["is_active"] = "Lol this should be a boolean"
        XCTAssertNil(Reservation.init(reservation: reservationDict))
    }

    func testInitReservationReturnsAReservationWhenFieldsAreValid() {
        XCTAssertNotNil(Reservation.init(reservation: reservationDict))
    }
}
