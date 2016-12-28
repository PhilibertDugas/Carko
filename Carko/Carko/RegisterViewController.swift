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
    var indicator: UIActivityIndicatorView?
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func registerPressed(_ sender: AnyObject) {
        if let firstName = firstName.text, let lastName = lastName.text, let email = email.text, let password = password.text {

            indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            let halfButtonHeight = registerButton.bounds.size.height / 2
            let buttonWidth = registerButton.bounds.size.width
            indicator?.center = CGPoint.init(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
            registerButton.addSubview(indicator!)
            indicator!.startAnimating()

            let customer = NewCustomer.init(email: email, password: password, firstName: firstName, lastName: lastName)
            customer.register()
        } else {
            super.displayErrorMessage("Please fill every fields")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.customerRegistered), name: NSNotification.Name(rawValue: "CustomerRegistered"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.customerRegisteredError), name: NSNotification.Name(rawValue: "CustomerRegisteredError"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

extension RegisterViewController {
    func customerRegistered(_ notification: Notification) {
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        Customer.getCustomer { (customer, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if let customer = customer {
                UserDefaults.standard.set(customer.toDictionnary(), forKey: "user")
                AppState.shared.customer = customer
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "UserRegistered", sender: nil)
            }
        }
    }

    func customerRegisteredError(_ notification: Notification) {
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        if let userInfo = notification.userInfo {
            super.displayErrorMessage(userInfo["data"] as! String)
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

