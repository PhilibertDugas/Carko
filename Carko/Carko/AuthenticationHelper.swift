//
//  FirebaseHelper.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-09.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth
import Crashlytics

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

    static func customerLoggedIn(_ customer: Customer) {
        AppState.shared.cacheCustomer(customer)
        Crashlytics.sharedInstance().setUserEmail(customer.email)
        Crashlytics.sharedInstance().setUserIdentifier(String(customer.id))
    }

    static func customerAvailable() -> Bool {
        let customer = AppState.shared.cachedCustomer()
        let authToken = AppState.shared.cachedToken()
        if FIRAuth.auth()?.currentUser == nil || customer == nil || authToken == nil {
            return false
        } else {
            return true
        }
    }

    // This should only be called is customerAvailable() returns true
    static func getCustomer() -> Customer {
        return AppState.shared.cachedCustomer()!
    }

    // This should only be called is customerAvailable() returns true
    static func getAuthToken() -> String {
        return AppState.shared.cachedToken()!
    }

    static func resetCustomer() {
        try! FIRAuth.auth()!.signOut()
        AppState.shared.resetCustomer()
    }
}
