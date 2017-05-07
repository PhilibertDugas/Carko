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

    @IBAction func menuTapped(_ sender: Any) {
        self.revealViewController().revealToggle(self)

    }

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
        if let city = cityTextField.text,
            let line1 = addressTextField.text,
            let postalCode = postalCodeTextField.text,
            let stateText = stateTextField.text,
            !city.isEmpty,
            !line1.isEmpty,
            !postalCode.isEmpty,
            !stateText.isEmpty {
            self.address = AccountAddress.init(city: city, line1: line1, postalCode: postalCode, state: stateText)
        } else {
            // FIXME : translate
            super.displayErrorMessage("PLEASE ENTER ALL FIELDS")
        }

        if let address = self.address, let dob = self.dob {
            self.account = Account.init(firstName: AppState.shared.customer.firstName, lastName: AppState.shared.customer.lastName, address: address, dob: dob)
            self.performSegue(withIdentifier: "showBankInformation", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setupProvincePicker()
        self.setupSidebar()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBankInformation" {
            let destination = segue.destination as! BankCreationViewController
            destination.account = self.account!
        }
    }
}

extension AccountCreationViewController: SWRevealViewControllerDelegate {
    fileprivate func setupSidebar() {
        let revealViewController = self.revealViewController()
        revealViewController?.delegate = self
        self.view.addGestureRecognizer((revealViewController?.panGestureRecognizer())!)
        AppState.setupRevealViewController(revealViewController!)
    }
}

extension AccountCreationViewController {
    func setupProvincePicker() {
        let pickerView = UIPickerView.init()
        pickerView.dataSource = self
        pickerView.delegate = self
        stateTextField.inputView = pickerView
    }
}

extension AccountCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppState.provinces.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AppState.provinces[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.stateTextField.text = AppState.provinces[row]
    }
}

extension AccountCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
