//
//  RegisterViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var errorMessage: UILabel!

    @IBAction func registerPressed(_ sender: AnyObject) {
        if let firstName = firstName.text, let lastName = lastName.text, let email = email.text, let password = password.text {
            let user = User.init(email: email, password: password, firstName: firstName, lastName: lastName)
            user.register()
        } else {
            print("Display an error message to the user")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.userRegistered), name: NSNotification.Name(rawValue: "UserRegistered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.userRegisteredError), name: NSNotification.Name(rawValue: "UserRegisteredError"), object: nil)
    }

    func userRegistered(_ notification: Notification) {
        self.performSegue(withIdentifier: "UserRegistered", sender: nil)
    }

    func userRegisteredError(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            errorMessage.text = userInfo["data"] as? String
        }
    }
}
