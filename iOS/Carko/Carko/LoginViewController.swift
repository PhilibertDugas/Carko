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

    @IBOutlet var loginButton: RoundedCornerButton!

    var indicator: UIActivityIndicatorView?
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if email.text == "" || password.text == "" {
            errorMessage.text = "Invalid email or password"
        } else {
            indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            let halfButtonHeight = loginButton.bounds.size.height / 2
            let buttonWidth = loginButton.bounds.size.width
            indicator?.center = CGPoint.init(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
            loginButton.addSubview(indicator!)
            indicator!.startAnimating()
            let customer = Customer.init(email: email.text!, password: password.text!)
            customer.logIn()
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.userLoggedIn), name: NSNotification.Name(rawValue: "CustomerLoggedIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.userLoggedInError), name: NSNotification.Name(rawValue: "CustomerLoggedInError"), object: nil)
    }

    func userLoggedIn(_ notification: Notification) {
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        Customer.getCustomer { (customer, error) in
            if let error = error {
                print("Shit something went wrong display something to the user: \(error.localizedDescription)")
            } else if let customer = customer {
                UserDefaults.standard.set(customer.toDictionnary(), forKey: "user")
                AppState.shared.customer = customer
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "UserLoggedIn", sender: nil)
            }
        }
    }

    func userLoggedInError(_ notification: Notification) {
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        if let userInfo = notification.userInfo {
            errorMessage.text = userInfo["data"] as? String
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

