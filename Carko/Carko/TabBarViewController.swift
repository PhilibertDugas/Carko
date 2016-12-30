//
//  TabBarViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-30.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseAuth

class TabBarViewController: UITabBarController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let customer = UserDefaults.standard.dictionary(forKey: "user")
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
        } else if AppState.shared.customer == nil {
            AppState.shared.customer = Customer.init(customer: customer!)
        }
    }
}
