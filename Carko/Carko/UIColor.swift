//
//  UIColor.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-26.
//  Copyright © 2016 QH4L. All rights reserved.
//
import UIKit
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }

    class var accentColor: UIColor {
        return UIColor.init(netHex: 0xC41134)
    }

    class var accentGradientColor: UIColor {
        return UIColor.init(netHex: 0xF5515F)
    }

    class var primaryGray: UIColor {
        return UIColor.init(netHex: 0xBFBFBF)
    }

    class var primaryBlack: UIColor {
        return UIColor.init(netHex: 0x252627)
    }

    class var backgroundBlack: UIColor {
        return UIColor.init(netHex: 0x181720)
    }

    class var secondaryViewsBlack: UIColor {
        return UIColor.init(netHex: 0x101415)
    }

    class var placeholderColor: UIColor {
        return UIColor.init(netHex: 0x505050)
    }

    class var primaryWhiteTextColor: UIColor {
        return UIColor.init(netHex: 0xE8E8E8)
    }
}
