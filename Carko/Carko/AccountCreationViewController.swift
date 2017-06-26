//
//  AccountCreationViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Crashlytics

class AccountCreationViewController: UIViewController {
    @IBOutlet var addressTextField: UnderlineTextField!
    @IBOutlet var cityTextField: UnderlineTextField!
    @IBOutlet var stateTextField: UnderlineTextField!
    @IBOutlet var postalCodeTextField: UnderlineTextField!
    @IBOutlet var countryTextField: UnderlineTextField!
    @IBOutlet var dobTextField: UnderlineTextField!
    @IBOutlet var continueButton: SmallRoundedCornerButton!

    var address: AccountAddress?
    var dob: AccountDateOfBirth?
    var account: Account?

    var completedView: PaymentSetupCompleted?

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        self.address = AccountAddress.init(city: cityTextField.text!, line1: addressTextField.text!, postalCode: postalCodeTextField.text!, state: stateTextField.text!)
        if let address = self.address, let dob = self.dob {
            self.account = Account.init(firstName: AuthenticationHelper.getCustomer().firstName, lastName: AuthenticationHelper.getCustomer().lastName, address: address, dob: dob)
            self.performSegue(withIdentifier: "showBankInformation", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = true
        self.hideKeyboardWhenTappedAround()
        self.setupProvincePicker()
        self.setupFields()

        self.addressTextField.attributedPlaceholder = NSAttributedString.init(string: Translations.t("Address"), attributes: [NSForegroundColorAttributeName: UIColor.placeholderColor])
        self.cityTextField.attributedPlaceholder = NSAttributedString.init(string: Translations.t("City"), attributes: [NSForegroundColorAttributeName: UIColor.placeholderColor])
        self.stateTextField.attributedPlaceholder = NSAttributedString.init(string: Translations.t("Province"), attributes: [NSForegroundColorAttributeName: UIColor.placeholderColor])
        self.postalCodeTextField.attributedPlaceholder = NSAttributedString.init(string: Translations.t("Postal Code"), attributes: [NSForegroundColorAttributeName: UIColor.placeholderColor])
        self.countryTextField.attributedPlaceholder = NSAttributedString.init(string: Translations.t("Country"), attributes: [NSForegroundColorAttributeName: UIColor.placeholderColor])
        self.dobTextField.attributedPlaceholder = NSAttributedString.init(string: Translations.t("Date of birth"), attributes: [NSForegroundColorAttributeName: UIColor.placeholderColor])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBankInformation" {
            let destination = segue.destination as! BankCreationViewController
            destination.account = self.account!
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.continueButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupBackgroundView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let completedView = self.completedView {
            completedView.frame = self.view.bounds
        }
    }

    fileprivate func setupBackgroundView() {
        if AppState.shared.customer.accountId != nil {
            self.completedView = PaymentSetupCompleted.init(frame: self.view.frame)
            self.completedView?.changeButton.addTarget(self, action: #selector(self.dismissBackgroundView), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.completedView!)
        } else {
            if let completedView = self.completedView {
                completedView.removeFromSuperview()
            }
        }
    }

    func dismissBackgroundView() {
        self.completedView?.removeFromSuperview()
    }
}

extension AccountCreationViewController {
    fileprivate func setupFields() {
        addressTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        cityTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        postalCodeTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        dobTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidEnd)
        stateTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidEnd)
    }

    func setupProvincePicker() {
        let pickerView = UIPickerView.init()
        pickerView.dataSource = self
        pickerView.delegate = self
        stateTextField.inputView = pickerView
    }

    func textChanged() {
        if TextFieldsValidator.fieldsAreFilled([addressTextField, cityTextField, stateTextField, postalCodeTextField, countryTextField, dobTextField]) {
            self.continueButton.isEnabled = true
            self.continueButton.alpha = 1.0
        } else {
            self.continueButton.isEnabled = false
            self.continueButton.alpha = 0.6
        }
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
