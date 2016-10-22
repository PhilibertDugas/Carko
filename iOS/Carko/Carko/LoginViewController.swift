//
//  LoginViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var errorMessage: UILabel!
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if email.text == "" || password.text == "" {
            errorMessage.text = "Invalid email or password"
        } else {
            let user = User.init(email: email.text!, password: password.text!)
            user.logIn()

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.userLoggedIn), name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.userLoggedInError), name: NSNotification.Name(rawValue: "UserLoggedInError"), object: nil)
    }

    func userLoggedIn(_ notification: Notification) {
        performSegue(withIdentifier: "UserLoggedIn", sender: nil)
    }

    func userLoggedInError(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            errorMessage.text = userInfo["data"] as? String
        }
    }
}
