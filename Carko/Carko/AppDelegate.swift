//
//  AppDelegate.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-02.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Firebase
import Stripe
import IQKeyboardManagerSwift
import UserNotifications
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true

        setupStripe()
        setupServers()
        setupPageControl()

        return true
    }

    fileprivate func setupStripe() {
        STPTheme.default().accentColor = UIColor.primaryWhiteTextColor
        STPTheme.default().primaryForegroundColor = UIColor.primaryWhiteTextColor

        STPTheme.default().primaryBackgroundColor = UIColor.secondaryViewsBlack
        STPTheme.default().secondaryBackgroundColor = UIColor.secondaryViewsBlack

        STPTheme.default().emphasisFont = UIFont.systemFont(ofSize: 18, weight: UIFontWeightHeavy)
        STPTheme.default()
    }

    fileprivate func setupPageControl() {
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.backgroundColor = UIColor.black
    }

    fileprivate func setupServers() {
        #if DEVELOPMENT
            let firebaseFile = "GoogleService-Info"
            let apiUrl = "https://integration-apya.herokuapp.com"
            STPPaymentConfiguration.shared().publishableKey = "pk_test_1LYkk7fCrA1bWDbXRUx1zWBx"
        #else
            let apiUrl = "https://apya.herokuapp.com"
            let firebaseFile = "GoogleService-Info-Production"
            STPPaymentConfiguration.shared().publishableKey = "pk_live_fo9Elk0ctw9i6vCBlSElK1EG"
            Fabric.with([Crashlytics.self])
        #endif

        let firebaseOptions = FIROptions(contentsOfFile: Bundle.main.path(forResource: firebaseFile, ofType: "plist"))
        FIRApp.configure(with: firebaseOptions!)
        APIClient.shared.baseUrl = URL.init(string: apiUrl)!
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Customer.updateCustomerToken(deviceTokenString) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

