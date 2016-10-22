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
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if let email = email.text, let password = password.text {
            let user = User.init(email: email, password: password)
            user.logIn()
        } else {
            print("Show an error message here")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.userLoggedIn), name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil)
    }
    
    func userLoggedIn(_ notification: Notification) {
        performSegue(withIdentifier: "UserLoggedIn", sender: nil)
    }
}
