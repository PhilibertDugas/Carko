//
//  DateHelperTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-25.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest
@testable import Carko

class DateHelperTest: XCTestCase {

    // Date format: "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let utcTime = "2017-06-26T00:00:00Z.000"

    func testGetDayOfWeekReturnsStringOfDayInTimezone() {
        NSTimeZone.default = TimeZone.init(abbreviation: "EST")!
        XCTAssertEqual("Sunday", DateHelper.getDayOfWeek(utcTime))

        NSTimeZone.default = TimeZone.init(abbreviation: "UTC")!
        XCTAssertEqual("Monday", DateHelper.getDayOfWeek(utcTime))
    }

    func testGetDayReturnsDayInTimezone() {
        NSTimeZone.default = TimeZone.init(abbreviation: "EST")!
        XCTAssertEqual(25, DateHelper.getDay(utcTime))

        NSTimeZone.default = TimeZone.init(abbreviation: "UTC")!
        XCTAssertEqual(26, DateHelper.getDay(utcTime))
    }

    func testGetMonthReturnsMonthInTimezone() {
        let utcMonthTime = "2017-06-01T00:00:00Z.000"
        NSTimeZone.default = TimeZone.init(abbreviation: "EST")!
        XCTAssertEqual("May", DateHelper.getMonth(utcMonthTime))

        NSTimeZone.default = TimeZone.init(abbreviation: "UTC")!
        XCTAssertEqual("June", DateHelper.getMonth(utcMonthTime))
    }
}
