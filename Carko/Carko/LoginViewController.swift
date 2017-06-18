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
            Customer.logIn(email: email, password: password) { (error) in
                if let error = error {
                    self.customerLoggedInError(error)
                }
                else {
                    self.customerLoggedIn()
                }
            }
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
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        destination.modalPresentationCapturesStatusBarAppearance = true
    }

    func customerLoggedIn() {
        indicator.stopAnimating()
        Customer.getCustomer { (customer, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if let customer = customer {
                AuthenticationHelper.customerLoggedIn(customer)
                self.dismiss(animated: true)
            }
        }
    }

    func customerLoggedInError(_ error: Error) {
        indicator.stopAnimating()
        super.displayErrorMessage(error.localizedDescription)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

