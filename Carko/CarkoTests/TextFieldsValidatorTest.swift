//
//  TextFieldsValidatorTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-22.
//  Copyright © 2017 QH4L. All rights reserved.
//

import XCTest

@testable import Carko


class TextFieldsValidatorTest: XCTestCase {

    var textFields: [(UITextField)] = []
    override func setUp() {
        super.setUp()
        let textField1 = UITextField.init()
        textField1.text = "Test1"
        let textField2 = UITextField.init()
        textField2.text = "Test1"

        textFields = [textField1, textField2]
    }

    func testFieldsAreFilledReturnsTrueWhenEverythingIsFilled() {
        XCTAssertTrue(TextFieldsValidator.fieldsAreFilled(textFields))
    }
    
    func testfieldsAreFilledReturnsFalseForNilValues() {
        textFields.first!.text = nil
        XCTAssertTrue(TextFieldsValidator.fieldsAreFilled(textFields))
    }

    func testfieldsAreFilledReturnsFalseForEmptyString() {
        textFields.first!.text = ""
        XCTAssertFalse(TextFieldsValidator.fieldsAreFilled(textFields))
    }
}
