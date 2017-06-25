//
//  CustomerTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-25.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest
@testable import Carko

class CustomerTest: XCTestCase {
    var customerDict: [String: Any]!
    override func setUp() {
        super.setUp()
        customerDict = [
            "id": 1,
            "firebase_id": "LULULUL123",
            "stripe_id": "cus_LULOLOL123",
            "email": "lulcustomer@gmail.com",
            "display_name": "Lul St-Pierre"
        ]
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitCustomerReturnsNilWhenMissingData() {
        let partialCustomer: [String: Any] = ["id": 1]
        XCTAssertNil(Customer.init(customer: partialCustomer))
    }

    func testInitCustomerReturnsNilWhenFieldsHaveInvalidTypes() {
        customerDict["id"] = "Lol this should be an integer"
        XCTAssertNil(Customer.init(customer: customerDict))
    }

    func testInitCustomerReturnsACustomertWhenFieldsAreValid() {
        XCTAssertNotNil(Customer.init(customer: customerDict))
    }
}
