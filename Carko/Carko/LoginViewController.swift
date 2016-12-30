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

    @IBOutlet var loginButton: RoundedCornerButton!
    @IBOutlet var indicator: UIActivityIndicatorView!

    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if let email = email.text, let password = password.text {
            indicator.startAnimating()
            Customer.logIn(email: email, password: password)
        } else {
            super.displayErrorMessage("Invalid email or password")
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.customerLoggedIn), name: NSNotification.Name(rawValue: "CustomerLoggedIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.customerLoggedInError), name: NSNotification.Name(rawValue: "CustomerLoggedInError"), object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        destination.modalPresentationCapturesStatusBarAppearance = true
    }

    func customerLoggedIn(_ notification: Notification) {
        indicator.stopAnimating()
        Customer.getCustomer { (customer, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if let customer = customer {
                UserDefaults.standard.set(customer.toDictionnary(), forKey: "user")
                AppState.shared.customer = customer
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "UserLoggedIn", sender: nil)
            }
        }
    }

    func customerLoggedInError(_ notification: Notification) {
        indicator.stopAnimating()
        if let userInfo = notification.userInfo {
            super.displayErrorMessage(userInfo["data"] as! String)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

