//
//  FirebaseHelper.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-09.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import Crashlytics

class AuthenticationHelper: NSObject {
    static let shared = AuthenticationHelper.init()
    var authUi: FUIAuth!

    class func customerLoggedIn(_ customer: Customer) {
        updateAuthToken({ (error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
        AppState.shared.cacheCustomer(customer)
        Crashlytics.sharedInstance().setUserEmail(customer.email)
        Crashlytics.sharedInstance().setUserIdentifier(String(customer.id))
    }

    class func customerAvailable() -> Bool {
        let customer = AppState.shared.cachedCustomer()
        let authToken = AppState.shared.cachedToken()
        if Auth.auth().currentUser == nil || customer == nil || authToken == nil {
            return false
        } else {
            return true
        }
    }

    // This should only be called is customerAvailable() returns true
    class func getCustomer() -> Customer {
        return AppState.shared.cachedCustomer()!
    }

    class func updateCustomer(_ customer: Customer) {
        AppState.shared.cacheCustomer(customer)
    }

    // This should only be called is customerAvailable() returns true
    class func getAuthToken() -> String {
        return AppState.shared.cachedToken()!
    }

    class func resetCustomer() {
        try! Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
        AppState.shared.resetCustomer()
    }

    private class func updateAuthToken(_ complete: @escaping (Error?) -> Void) {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
            if let error = error {
                complete(error)
            } else if let token = idToken {
                AppState.shared.cacheAuthToken(token)
                complete(nil)
            }
        })
    }
}

extension AuthenticationHelper: FUIAuthDelegate {
    func getAuthUI() -> FUIAuth {
        if authUi != nil {
            return authUi
        }
        authUi = FUIAuth.defaultAuthUI()
        authUi.providers = [FUIFacebookAuth.init()]
        authUi.tosurl = URL.init(string: AppState.companyEmail)
        authUi.delegate = self
        return authUi
    }

    func getAuthController() -> UIViewController {
        let controller = getAuthUI().authViewController() as UINavigationController
        controller.navigationBar.barTintColor = UIColor.secondaryViewsBlack
        controller.navigationBar.isTranslucent = true
        controller.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        controller.navigationBar.tintColor = UIColor.white
        return controller
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let current = FBSDKAccessToken.current() {
            let credential = FacebookAuthProvider.credential(withAccessToken: current.tokenString)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    Crashlytics.sharedInstance().recordError(error)
                } else if let user = user {
                    self.ensureCustomerInBackend(user)
                }
            })
        } else if let user = user {
            self.ensureCustomerInBackend(user)
        }
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return AuthPickerViewController(nibName: "AuthPickerViewController", bundle: Bundle.main, authUI: authUI)
    }

    private func ensureCustomerInBackend(_ user: User) {
        Customer.getCustomer { (customer, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else if let customer = customer {
                AuthenticationHelper.customerLoggedIn(customer)
            } else {
                // New customer flow
                let newCustomer = NewCustomer.init(email: user.email!, displayName: user.displayName!, firebaseId: user.uid)
                newCustomer.register(complete: { (error) in
                    if error != nil {
                        try! Auth.auth().signOut()
                    } else {
                        self.initCustomer()
                    }
                })
            }
        }
    }

    private func initCustomer() {
        Customer.getCustomer { (customer, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else if let customer = customer {
                AuthenticationHelper.customerLoggedIn(customer)
            }
        }
    }
}
