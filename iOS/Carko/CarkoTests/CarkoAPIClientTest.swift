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

class CarkoAPIClientTest: XCTestCase {

    var client: CarkoAPIClient!
    var newParking: Parking!

    override func setUp() {
        super.setUp()
        self.client = CarkoAPIClient.sharedClient

        self.newParking = Parking.init(latitude: CLLocationDegrees.init(-74.00), longitude: CLLocationDegrees.init(135.00), photoURL: URL.init(string: "www.test.com")!, address: "1160 Rue Villeray", price: 2.00, parkingDescription: "Unit Test Parking", availabilityInfo: ParkingAvailabilityInfo.init())

        OHHTTPStubs.setEnabled(true)
        OHHTTPStubs.onStubActivation { (request: URLRequest, stub: OHHTTPStubsDescriptor, response: OHHTTPStubsResponse) in
            print("[OHHTTPStubs] Request to \(request.url!) has been stubbed with \(stub.name)")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testNoErrorWhenCreateParkingSuccess() {
        let postStub = stub(condition: isMethodPOST() && isPath("/parkings")) { _ in
            return OHHTTPStubsResponse.init(data: Data.init(), statusCode: 201, headers: nil)
        }
        postStub.name = "Post Parking Success"

        let successExpectation = expectation(description: "PostParkingSuccess")

        self.client.createParking(parking: self.newParking) { (error) in
            XCTAssertNil(error)
            successExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testErrorReturnedWhenCreateParkingFails() {
        let postStub = stub(condition: isMethodPOST() && isPath("/parkings")) { _ in
            return OHHTTPStubsResponse.init(error: NSError.init(domain: "Error posting", code: 100, userInfo: nil))
        }
        postStub.name = "Post Parking Failure"

        let successExpectation = expectation(description: "PostParkingFailure")

        self.client.createParking(parking: self.newParking) { (error) in
            XCTAssertNotNil(error)
            successExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
