//
//  AppDelegate.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-02.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FBSDKCoreKit
import Stripe
import IQKeyboardManagerSwift
import UserNotifications
import Fabric
import Crashlytics
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true

        UIApplication.shared.statusBarView?.backgroundColor = UIColor.secondaryViewsBlack

        setupStripe()
        setupServers()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        validateCachedInfo()

        return true
    }

    private func setupStripe() {
        STPTheme.default().accentColor = UIColor.primaryWhiteTextColor
        STPTheme.default().primaryForegroundColor = UIColor.primaryWhiteTextColor

        STPTheme.default().primaryBackgroundColor = UIColor.secondaryViewsBlack
        STPTheme.default().secondaryBackgroundColor = UIColor.secondaryViewsBlack

        STPTheme.default().emphasisFont = UIFont.systemFont(ofSize: 18, weight: UIFontWeightHeavy)
        STPTheme.default()
    }

    private func setupServers() {
        #if DEVELOPMENT
            let firebaseFile = "GoogleService-Info"
            let apiUrl = "https://integration-apya.herokuapp.com"
            STPPaymentConfiguration.shared().publishableKey = "pk_test_1LYkk7fCrA1bWDbXRUx1zWBx"
            GMSServices.provideAPIKey("AIzaSyDxqMJFAynsWULks32Bj1826DEqcQkRe9g")
        #else
            let apiUrl = "https://apya.herokuapp.com"
            let firebaseFile = "GoogleService-Info-Production"
            STPPaymentConfiguration.shared().publishableKey = "pk_live_fo9Elk0ctw9i6vCBlSElK1EG"
            GMSServices.provideAPIKey("AIzaSyA-9Er9BVKR1LTft9kLsyIzdv3uHlKRvZ8")
            Fabric.with([Crashlytics.self])
        #endif

        let firebaseOptions = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: firebaseFile, ofType: "plist")!)
        FirebaseApp.configure(options: firebaseOptions!)
        APIClient.shared.baseUrl = URL.init(string: apiUrl)!
    }

    private func validateCachedInfo() {
        let cachedVersion = UserDefaults.standard.string(forKey: "environment")
        if let version = cachedVersion {
            #if DEVELOPMENT
                if version != "dev" {
                    UserDefaults.standard.setValue("dev", forKey: "environment")
                    AuthenticationHelper.resetCustomer()
                }
            #else
                if version != "prod" {
                    UserDefaults.standard.setValue("prod", forKey: "environment")
                    AuthenticationHelper.resetCustomer()
                }
            #endif
        } else {
            #if DEVELOPMENT
                UserDefaults.standard.setValue("dev", forKey: "environment")
            #else
                AuthenticationHelper.resetCustomer()
                UserDefaults.standard.setValue("prod", forKey: "environment")
            #endif
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Customer.updateCustomerToken(deviceTokenString) { (error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            }
        }
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        let annotations = options[UIApplicationOpenURLOptionsKey.annotation]
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotations)
    }
}

