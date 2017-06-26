//
//  LocalParkingManagerTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-26.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest
@testable import Carko

class LocalParkingManagerTest: XCTestCase {

    let parkingManager = LocalParkingManager.shared

    override func setUp() {
        super.setUp()
        parkingManager.setParkings([])
    }

    func testSetParkingsInitializeTheParkings() {
        parkingManager.setParkings([Parking.init(), Parking.init()])
        XCTAssertEqual(2, parkingManager.getParkings().count)
    }

    func testInsertParkingAppendsParkings() {
        parkingManager.setParkings([Parking.init()])
        parkingManager.insertParking(Parking.init())
        XCTAssertEqual(2, parkingManager.getParkings().count)
    }

    func testUpdateParkingUpdatesTheParking() {
        let parking = Parking.init()
        parking.id = 1
        parkingManager.setParkings([parking])

        parking.address = "Salut Salut"
        parkingManager.updateParking(parking)

        XCTAssertEqual("Salut Salut", parkingManager.getParkings().first??.address)
    }

    func testUpdateParkingWithoutIdDoesNothing() {
        parkingManager.setParkings([Parking.init()])

        let parking = Parking.init()
        parking.id = 1
        parking.address = "Salut Salut"
        parkingManager.updateParking(parking)

        XCTAssertEqual("Select a location", parkingManager.getParkings().first??.address)
    }

    func testUpdateParkingWithNilIdDoesNothing() {
        parkingManager.setParkings([Parking.init()])

        let parking = Parking.init()
        parking.id = nil
        parking.address = "Salut Salut"
        parkingManager.updateParking(parking)

        XCTAssertEqual("Select a location", parkingManager.getParkings().first??.address)
    }

    func testRemoveParkingRemovesTheParking() {
        let parking = Parking.init()
        parking.id = 1
        parkingManager.setParkings([parking])

        XCTAssertEqual(1, parkingManager.getParkings().count)

        parkingManager.removeParking(parking)

        XCTAssertEqual(0, parkingManager.getParkings().count)
    }

    func testRemoveParkingWithoutAnIdDoesNothing() {
        parkingManager.setParkings([Parking.init()])

        XCTAssertEqual(1, parkingManager.getParkings().count)

        let parking = Parking.init()
        parking.id = 1
        parkingManager.removeParking(parking)

        XCTAssertEqual(1, parkingManager.getParkings().count)
    }

    func testRemoveParkingWithNilIdDoesNothing() {
        parkingManager.setParkings([Parking.init()])

        XCTAssertEqual(1, parkingManager.getParkings().count)

        let parking = Parking.init()
        parking.id = nil
        parkingManager.removeParking(parking)

        XCTAssertEqual(1, parkingManager.getParkings().count)
    }
}
