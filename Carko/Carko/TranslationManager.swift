//
//  TranslationManager.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-22.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

struct Translations {
    static func t(_ s: String) -> String {
        return NSLocalizedString(s, comment: "")
    }
}
