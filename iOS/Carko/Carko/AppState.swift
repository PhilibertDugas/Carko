//
//  AppState.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-27.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseStorage

class AppState: NSObject {
    static let sharedInstance = AppState.init()

    var currentUser: User!
    let storageReference = FIRStorage.storage().reference(forURL: "gs://carko-1475431423846.appspot.com")
}
