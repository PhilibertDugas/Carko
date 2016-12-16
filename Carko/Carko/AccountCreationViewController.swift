//
//  AccountCreationViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class AccountCreationViewController: UIViewController {

    @IBOutlet var addressTextField: UnderlineTextField!
    @IBOutlet var cityTextField: UnderlineTextField!
    @IBOutlet var stateTextField: UnderlineTextField!
    @IBOutlet var postalCodeTextField: UnderlineTextField!
    @IBOutlet var countryTextField: UnderlineTextField!
    @IBOutlet var dobTextField: UnderlineTextField!

    var address: AccountAddress?
    var dob: AccountDateOfBirth?
    var account: Account?

    @IBAction func nextTapped(_ sender: Any) {
        if let city = cityTextField.text, let line1 = addressTextField.text, let postalCode = postalCodeTextField.text, let stateText = stateTextField.text {
            self.address = AccountAddress.init(city: city, line1: line1, postalCode: postalCode, state: stateText)
        } else {
            print("BRUH")
        }

        if let dateOfBirth = dobTextField.text {
            // FIXME that sucks
            let dateArray = dateOfBirth.characters.split(separator: " ").map(String.init)
            self.dob = AccountDateOfBirth.init(day: dateArray[0], month: dateArray[1], year: dateArray[2])
        } else {
            print("need to know when u were born")
        }

        if let address = self.address, let dob = self.dob {
            self.account = Account.init(firstName: AppState.shared.customer.firstName, lastName: AppState.shared.customer.lastName, address: address, dob: dob)

            self.account!.persist { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "showBankInformation", sender: nil)
                }
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if AppState.shared.customer.accountId != nil {
            self.performSegue(withIdentifier: "showBankInformation", sender: nil)
        }
    }
}
