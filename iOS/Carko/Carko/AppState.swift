//
//  AppState.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-27.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class AppState: NSObject {
    static let sharedInstance = AppState.init()

    var currentUser: User?
}
