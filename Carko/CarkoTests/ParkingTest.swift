//
//  CarkoAPIClientTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import XCTest
import CoreLocation
import OHHTTPStubs
@testable import Carko

class ParkingTest: XCTestCase {
    var newParking: Parking!

    override func setUp() {
        super.setUp()
        self.newParking = Parking.init(latitude: CLLocationDegrees.init(-74.00),longitude: CLLocationDegrees.init(135.00),photoURL: URL.init(string: "www.test.com")!, address: "1160 Rue Villeray", price: 2.00, pDescription: "Unit Test Parking", isAvailable: true, availabilityInfo: AvailabilityInfo.init(), customerId: 1)
        self.newParking.id = 1

        OHHTTPStubs.setEnabled(true)
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testNoErrorWhenPersistWorked() {
        let postStub = stub(condition: isMethodPOST() && isPath("/parkings")) { _ in
            return OHHTTPStubsResponse.init(data: Data.init(), statusCode: 201, headers: nil)
        }
        postStub.name = "Post Parking Success"

        let successExpectation = expectation(description: "PostParkingSuccess")
        self.newParking.persist { (error) in
            XCTAssertNil(error)
            successExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testErrorReturnedWhenPersistFailed() {
        let postStub = stub(condition: isMethodPOST() && isPath("/parkings")) { _ in
            return OHHTTPStubsResponse.init(error: NSError.init(domain: "Error posting", code: 100, userInfo: nil))
        }
        postStub.name = "Post Parking Failure"

        let successExpectation = expectation(description: "PostParkingFailure")

        self.newParking.persist { (error) in
            XCTAssertNotNil(error)
            successExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testNoErrorWhenUpdateWorked() {
        let updateStub = stub(condition: isMethodPATCH()) { _ in
            return OHHTTPStubsResponse.init(data: Data.init(), statusCode: 200, headers: nil)
        }
        updateStub.name = "Patch Parking Success"

        let successExpectation = expectation(description: "PatchParkingSuccess")
        self.newParking.update { (error) in
            XCTAssertNil(error)
            successExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testErrorReturnedWhenUpdateFailed() {
        let updateStub = stub(condition: isMethodPATCH()) { _ in
            return OHHTTPStubsResponse.init(error: NSError.init(domain: "Error posting", code: 100, userInfo: nil))
        }
        updateStub.name = "Patch Parking Failure"

        let successExpectation = expectation(description: "PatchParkingFailure")

        self.newParking.update { (error) in
            XCTAssertNotNil(error)
            successExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testParkingIsSerializable() {
        let parkingDict = newParking.toDictionary()
        XCTAssertEqual(newParking.latitude, parkingDict["latitude"] as! CLLocationDegrees)
        XCTAssertEqual(newParking.longitude, parkingDict["longitude"] as!CLLocationDegrees)
        XCTAssertEqual(newParking.photoURL!.absoluteString, parkingDict["photo_url"] as! String)
        XCTAssertEqual(newParking.address, parkingDict["address"] as! String)
        XCTAssertEqual(String.init(format: "%.2f",newParking.price), parkingDict["price"] as! String)
        XCTAssertEqual(newParking.pDescription, parkingDict["description"] as! String)
        XCTAssertEqual(newParking.isAvailable, parkingDict["is_available"] as! Bool)
        let availabilityInfo = AvailabilityInfo.init(availabilityInfo: parkingDict["availability_info"] as! [String: Any])
        XCTAssertEqual(newParking.availabilityInfo, availabilityInfo)
        XCTAssertEqual(newParking.customerId, parkingDict["customer_id"] as! Int)
    }

    func testStopDateReturnsInSpecificFormat() {
        let todayFormater = DateFormatter.init()
        todayFormater.dateFormat = "d.M.yyyy"
        todayFormater.timeZone = NSTimeZone.local
        let todayString = todayFormater.string(from: Date.init())
        let convertString = "\(todayString) \(self.newParking.availabilityInfo.stopTime)"
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "d.M.yyyy HH:mm"
        dateFormatter.timeZone = NSTimeZone.local
        let expectedDate = dateFormatter.date(from: convertString)!
        let date = self.newParking.stopDate()
        XCTAssertEqual(expectedDate, date)
    }
}
