//
//  BankCreationViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe

class BankCreationViewController: UIViewController {
    @IBOutlet var routingNumberTextField: UnderlineTextField!
    @IBOutlet var accountNumberTextField: UnderlineTextField!

    var account: Account!

    @IBAction func BankInformationEntered(_ sender: Any) {
        if let routingNumber = routingNumberTextField.text, let accountNumber = accountNumberTextField.text {
            createAccounts(routingNumber: routingNumber, accountNumber: accountNumber)
        }
    }

    func createAccounts(routingNumber: String, accountNumber: String) {
        self.account.persist { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let params = STPBankAccountParams.init()
                params.accountHolderName = "\(AppState.shared.customer.firstName) \(AppState.shared.customer.lastName)"
                params.accountHolderType = STPBankAccountHolderType.individual
                params.accountNumber = accountNumber
                params.routingNumber = routingNumber
                params.country = "CA"
                params.currency = "CAD"
                STPAPIClient.shared().createToken(withBankAccount: params, completion: { (token, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let token = token?.tokenId {
                        Account.associateExternalAccount(token: token, completion: { (error) in
                            if error != nil {
                                print("tbk")
                            } else {
                                let _ = self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                    }
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
}
