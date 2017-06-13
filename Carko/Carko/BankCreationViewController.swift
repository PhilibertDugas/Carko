//
//  BankCreationViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe
import SCLAlertView

class BankCreationViewController: UIViewController {
    @IBOutlet var routingNumberTextField: UnderlineTextField!
    @IBOutlet var accountNumberTextField: UnderlineTextField!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var account: Account!

    @IBAction func saveTapped(_ sender: Any) {
        if let routingNumber = routingNumberTextField.text, !routingNumber.isEmpty, let accountNumber = accountNumberTextField.text, !accountNumber.isEmpty {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            createAccounts(routingNumber: routingNumber, accountNumber: accountNumber)
        }
    }

    func createAccounts(routingNumber: String, accountNumber: String) {
        self.account.persist { (error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                super.displayErrorMessage(error.localizedDescription)
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
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        super.displayErrorMessage(error.localizedDescription)
                    } else if let token = token {
                        Account.associateExternalAccount(token: token.tokenId, completion: { (error) in
                            if let error = error {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                super.displayErrorMessage(error.localizedDescription)
                            } else {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                AppState.shared.cacheBankToken(token)
                                self.displaySuccessMessage()
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
        self.activityIndicator.isHidden = true
        // FIXME : Translate
        self.routingNumberTextField.attributedPlaceholder = NSAttributedString.init(string: "Routing Number", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.accountNumberTextField.attributedPlaceholder = NSAttributedString.init(string: "Account Number", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])


    }

    func displaySuccessMessage() {
        // FIXME
        let responder = SCLAlertView.init().showSuccess(NSLocalizedString("Congratulations", comment: ""), subTitle: NSLocalizedString("You just added your payout information", comment: ""))
        responder.setDismissBlock {
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
