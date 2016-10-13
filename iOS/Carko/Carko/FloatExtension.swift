//
//  FloatExtension.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-13.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

extension Float {
    var asLocaleCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self))!
    }
    
    var asCurrency: Float {
        let divisor = pow(10.0, Float(2))
        return (self * divisor).rounded() / divisor
    }
}

