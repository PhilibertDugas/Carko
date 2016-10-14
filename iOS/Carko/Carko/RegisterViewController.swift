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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userRegistered(_ notification: Notification) {
        self.performSegue(withIdentifier: "UserRegistered", sender: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
