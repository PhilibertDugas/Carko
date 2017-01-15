//
//  DateHelper.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-15.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

struct DateHelper {
    static func currentTime() -> String {
        return AvailabilityInfo.formatter().string(from: Date.init())
    }
}
