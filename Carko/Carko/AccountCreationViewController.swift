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

    @IBAction func timeEditBegin(_ sender: UITextField) {
        let datePicker = UIDatePicker.init()
        datePicker.datePickerMode = UIDatePickerMode.date
        if sender.text != "" {
            let formatter = DateFormatter.init()
            formatter.dateFormat = "dd-MM-yyyy"
            let date = formatter.date(from: sender.text!)
            datePicker.date = date!
        }
        sender.inputView = datePicker
    }

    @IBAction func timeEditEnd(_ sender: UITextField) {
        let datePicker = sender.inputView as! UIDatePicker
        let day = String.init(format: "%02d", Calendar.current.component(Calendar.Component.day, from: datePicker.date))
        let month = String.init(format: "%02d", Calendar.current.component(Calendar.Component.month, from: datePicker.date))
        let year = String.init(Calendar.current.component(Calendar.Component.year, from: datePicker.date))
        self.dob = AccountDateOfBirth.init(day: day, month: month, year: year)
        sender.text = "\(day)-\(month)-\(year)"
    }

    @IBAction func continueTapped(_ sender: Any) {
        if let city = cityTextField.text, let line1 = addressTextField.text, let postalCode = postalCodeTextField.text, let stateText = stateTextField.text {
            self.address = AccountAddress.init(city: city, line1: line1, postalCode: postalCode, state: stateText)
        } else {
            super.displayErrorMessage("Please enter all fields")
        }

        if let address = self.address, let dob = self.dob {
            self.account = Account.init(firstName: AppState.shared.customer.firstName, lastName: AppState.shared.customer.lastName, address: address, dob: dob)
            self.performSegue(withIdentifier: "showBankInformation", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBankInformation" {
            let destination = segue.destination as! BankCreationViewController
            destination.account = self.account!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
}

extension AccountCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
