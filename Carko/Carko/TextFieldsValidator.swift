//
//  TextFieldsValidator.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-22.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import UIKit

struct TextFieldsValidator {
    static func fieldsAreFilled(_ fields: [(UITextField)]) -> Bool {
        for field in fields {
            if field.text == nil || (field.text?.isEmpty)! {
                return false
            }
        }
        return true
    }
}
