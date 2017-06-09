//
//  FirebaseHelper.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-09.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth

struct AuthenticationHelper {
    static func updateAuthToken(_ complete: @escaping (Error?) -> Void) {
        let currentUser = FIRAuth.auth()?.currentUser
        currentUser?.getTokenForcingRefresh(true, completion: { (idToken, error) in
            if let error = error {
                complete(error)
            } else if let token = idToken {
                AppState.shared.cacheAuthToken(token)
                complete(nil)
            }
        })
    }

    static func customerAvailable() -> Bool {
        let customer = AppState.shared.cachedCustomer()
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            return false
        } else {
            return true
        }
    }

    // This should only be called is customerAvailable() returns true
    static func getCustomer() -> Customer {
        return AppState.shared.cachedCustomer()!
    }

    static func resetCustomer() {
        try! FIRAuth.auth()!.signOut()
        AppState.shared.resetCustomer()
    }
}
