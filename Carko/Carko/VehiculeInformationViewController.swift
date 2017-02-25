//
//  VehiculeInformationViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import SCLAlertView

class VehiculeInformationViewController: UIViewController {
    @IBOutlet var licensePlateTextField: UnderlineTextField!
    @IBOutlet var makeTextField: UnderlineTextField!
    @IBOutlet var modelTextField: UnderlineTextField!
    @IBOutlet var yearTextField: UnderlineTextField!
    @IBOutlet var colorTextField: UnderlineTextField!
    @IBOutlet var provinceTextField: UnderlineTextField!
    @IBOutlet var saveButton: RoundedCornerButton!

    var years: [(String)] = []
    let provinces = ["AB", "BC", "MB", "NB", "NL", "NS", "ON", "PE", "QC", "SK"]
    let licensePlateLength = 6

    @IBAction func saveTapped(_ sender: Any) {
        if allFieldsFilled() {
            let vehicule = Vehicule.init(license: licensePlateTextField.text!, make: makeTextField.text!, model: modelTextField.text!, year: yearTextField.text!, color: colorTextField.text!, province: provinceTextField.text!)
            vehicule.persist(completion: { (error) in
                if let error = error {
                    super.displayErrorMessage(error.localizedDescription)
                } else {
                    AppState.shared.cacheVehicule(vehicule)
                    self.displaySuccessMessage()
                }
            })
        } else {
            super.displayErrorMessage("PLEASE MAKE SURE TO ENTER ALL FIELDS")
        }
    }

    func textChanged() {
        if allFieldsFilled() {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        }
    }

    func allFieldsFilled() -> Bool {
        return licensePlateTextField.text != nil && makeTextField.text != nil && modelTextField.text != nil && yearTextField.text != nil && colorTextField.text != nil && provinceTextField.text != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setupYears()
        setupFields()
        setupPickers()
    }

    func setupYears() {
        for i in 1960...currentYear() {
            years.append("\(i)")
        }
    }

    func currentYear() -> Int {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy"
        return Int(formatter.string(from: Date.init()))!
    }

    func setupFields() {
        if let vehicule = AppState.shared.customer.vehicule {
            licensePlateTextField.text = vehicule.license
            makeTextField.text = vehicule.make
            modelTextField.text = vehicule.model
            yearTextField.text = vehicule.year
            colorTextField.text = vehicule.color
            provinceTextField.text = vehicule.province
        }

        licensePlateTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        licensePlateTextField.delegate = self
        makeTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        modelTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        yearTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidBegin)
        colorTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        provinceTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidBegin)
    }

    func displaySuccessMessage() {
        let responder = SCLAlertView.init().showSuccess(NSLocalizedString("Congratulations", comment: ""), subTitle: NSLocalizedString("You just added your vehicule", comment: ""))
        responder.setDismissBlock {
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension VehiculeInformationViewController {
    func setupPickers() {
        setupYearPicker()
        setupProvincePicker()
    }

    func setupYearPicker() {
        let pickerView = UIPickerView.init()
        pickerView.tag = 10
        pickerView.dataSource = self
        pickerView.delegate = self
        yearTextField.inputView = pickerView
        var selectedRow: Int
        if let year = self.yearTextField.text {
            if year != "" {
                selectedRow = self.years.index(of: year)!
            } else {
                selectedRow = self.years.index(of: "\(currentYear())")!
            }
        } else {
            selectedRow = self.years.index(of: "\(currentYear())")!
        }
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)

    }

    func setupProvincePicker() {
        let pickerView = UIPickerView.init()
        pickerView.tag = 11
        pickerView.dataSource = self
        pickerView.delegate = self
        provinceTextField.inputView = pickerView
        var selectedRow: Int
        if let province = self.provinceTextField.text {
            if province != "" {
                selectedRow = self.provinces.index(of: province)!
                pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
        }
    }
}

extension VehiculeInformationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= licensePlateLength
    }
}

extension VehiculeInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 10:
            return self.years.count
        case 11:
            return self.provinces.count
        default:
            break
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 10:
            return self.years[row]
        case 11:
            return self.provinces[row]
        default:
            break
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 10:
            self.yearTextField.text = self.years[row]
            break
        case 11:
            self.provinceTextField.text = self.provinces[row]
            break
        default:
            break
        }
    }
}
