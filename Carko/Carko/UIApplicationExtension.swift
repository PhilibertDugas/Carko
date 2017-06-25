//
//  UIApplicationExtension.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-25.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
