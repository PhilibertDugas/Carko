//
//  ForgotPasswordViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-30.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    @IBOutlet var emailTextField: UnderlineTextField!

    @IBAction func resetTapped(_ sender: Any) {
        if let email = emailTextField.text {
            FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    self.displayErrorMessage(error.localizedDescription)
                } else {
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            super.displayErrorMessage("")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()
    }
}
