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

    @IBOutlet var saveButton: SmallRoundedCornerButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var account: Account!
    var manager: PopupManager!

    @IBAction func saveTapped(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        createAccounts(routingNumber: self.routingNumberTextField.text!, accountNumber: self.accountNumberTextField.text!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.activityIndicator.isHidden = true
        self.setupFields()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        saveButton.isEnabled = false
    }
}

extension BankCreationViewController {
    fileprivate func setupFields() {
        // FIXME : Translate
        self.routingNumberTextField.attributedPlaceholder = NSAttributedString.init(string: "Routing Number", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.accountNumberTextField.attributedPlaceholder = NSAttributedString.init(string: "Account Number", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.routingNumberTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        self.accountNumberTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
    }

    func textChanged() {
        if allFieldsFilled() {
            self.saveButton.isEnabled = true
            self.saveButton.alpha = 1.0
        } else {
            self.saveButton.isEnabled = false
            self.saveButton.alpha = 0.6
        }
    }

    func allFieldsFilled() -> Bool {
        return routingNumberTextField.text != "" && accountNumberTextField.text != ""
    }
}

extension BankCreationViewController {
    fileprivate func createAccounts(routingNumber: String, accountNumber: String) {
        self.account.persist { (error) in
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                super.displayErrorMessage(error.localizedDescription)
            } else {
                let params = STPBankAccountParams.init()
                params.accountHolderName = AuthenticationHelper.getCustomer().displayName
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

    private func displaySuccessMessage() {
        // fixme translate
        manager = PopupManager.init(parentView: self.view, title: NSLocalizedString("Congratulations", comment: ""), description: NSLocalizedString("You just added your payout information", comment: ""))
        manager.successPopup.confirmButton.addTarget(self, action: #selector(self.dismissPopup), for: .touchUpInside)
        manager.displayPopup()
    }

    func dismissPopup(_ sender: UIButton) {
        manager.removePopup()
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
