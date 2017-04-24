//
//  StringExtension.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-23.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

extension String {
    // format: yyyy-mm-ddTHH:mm:ss.msZ

    var formattedDays: String {
        return (self.components(separatedBy: "T").first)!
    }

    var formattedHours: String {
        let time = self.components(separatedBy: "T").last!
        let strippedHours = time.components(separatedBy: ".").first!
        return strippedHours
    }

    var formattedTime: String {
        return "\(self.formattedDays) \(self.formattedHours)"
    }
    
}
