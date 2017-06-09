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
    @IBOutlet var registerButton: RoundedCornerButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var indicator: UIActivityIndicatorView!

    @IBAction func tosTapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://stripe.com/ca/connect-account/legal")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerPressed(_ sender: AnyObject) {
        if let firstName = firstName.text, let lastName = lastName.text, let email = email.text, let password = password.text {
            indicator.startAnimating()
            let customer = NewCustomer.init(email: email, password: password, firstName: firstName, lastName: lastName)
            customer.register(complete: { (error) in
                if let error = error {
                    self.customerRegisteredError(error)
                } else {
                    self.customerRegistered()
                }
            })
        } else {
            super.displayErrorMessage("Please fill every fields")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

extension RegisterViewController {
    func customerRegistered() {
        indicator.stopAnimating()
        Customer.getCustomer { (customer, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if let customer = customer {
                AppState.shared.cacheCustomer(customer)
                self.dismiss(animated: true)
            }
        }
    }

    func customerRegisteredError(_ error: Error) {
        indicator.stopAnimating()
        super.displayErrorMessage(error.localizedDescription)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

