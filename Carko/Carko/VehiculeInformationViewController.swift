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
    let licensePlateLength = 6

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: Any) {
        let vehicule = Vehicule.init(license: licensePlateTextField.text!, make: makeTextField.text!, model: modelTextField.text!, year: yearTextField.text!, color: colorTextField.text!, province: provinceTextField.text!)
        vehicule.persist(completion: { (error, vehicule) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if let vehicule = vehicule {
                var customer = AuthenticationHelper.getCustomer()
                customer.vehicule = vehicule
                customer.updateCustomer({ (error) in
                    if let error = error {
                        self.displayErrorMessage(error.localizedDescription)
                    } else {
                        AppState.shared.cacheVehicule(vehicule)
                        self.displaySuccessMessage()
                    }
                })
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = true
        self.hideKeyboardWhenTappedAround()
        setupYears()
        setupFields()
        setupPickers()
        // FIXME: Translate
        self.licensePlateTextField.attributedPlaceholder = NSAttributedString.init(string: "License Plate", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.makeTextField.attributedPlaceholder = NSAttributedString.init(string: "Make", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.modelTextField.attributedPlaceholder = NSAttributedString.init(string: "Model", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.yearTextField.attributedPlaceholder = NSAttributedString.init(string: "Year", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.colorTextField.attributedPlaceholder = NSAttributedString.init(string: "Color", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])
        self.provinceTextField.attributedPlaceholder = NSAttributedString.init(string: "Province", attributes: [NSForegroundColorAttributeName: UIColor.primaryGray])

    }
}

extension VehiculeInformationViewController {
    func textChanged() {
        if allFieldsFilled() {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        } else {
            saveButton.alpha = 0.6
            saveButton.isEnabled = false
        }
    }

    func allFieldsFilled() -> Bool {
        for field in [licensePlateTextField, makeTextField, modelTextField, yearTextField, colorTextField, provinceTextField] {
            if field?.text == nil || (field?.text?.isEmpty)! {
                return false
            }
        }
        return true
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

    fileprivate func setupFields() {
        if let vehicule = AuthenticationHelper.getCustomer().vehicule {
            licensePlateTextField.text = vehicule.license
            makeTextField.text = vehicule.make
            modelTextField.text = vehicule.model
            yearTextField.text = vehicule.year
            colorTextField.text = vehicule.color
            provinceTextField.text = vehicule.province
        }

        licensePlateTextField.addTarget(self, action: #selector(self.licensePlateCheck), for: UIControlEvents.editingDidEnd)
        licensePlateTextField.delegate = self
        makeTextField.addTarget(self, action: #selector(self.makeFieldReset), for: UIControlEvents.editingDidEnd)
        modelTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidEnd)
        yearTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidEnd)
        colorTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidEnd)
        provinceTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingDidEnd)
    }

    func licensePlateCheck() {
        if VehiculeHelper.isValidPlate(licensePlateTextField.text!) {
            licensePlateTextField.tintColor = UIColor.primaryWhiteTextColor
            self.textChanged()
        } else {
            self.licensePlateTextField.tintColor = UIColor.accentColor
        }
    }

    func makeFieldReset() {
        modelTextField.text = nil
        self.textChanged()
    }

    func displaySuccessMessage() {
        // FIXME : Remove SCLs
        let responder = SCLAlertView.init().showSuccess(NSLocalizedString("Congratulations", comment: ""), subTitle: NSLocalizedString("You just added your vehicule", comment: ""))
        responder.setDismissBlock {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension VehiculeInformationViewController {
    func setupPickers() {
        setupYearPicker()
        setupProvincePicker()
        setupMakePicker()
        setupModelPicker()
        setupColorPicker()
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
        if let province = self.provinceTextField.text {
            if province != "" {
                let selectedRow = AppState.provinces.index(of: province)!
                pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
        }
    }

    func setupMakePicker() {
        let pickerView = UIPickerView.init()
        pickerView.tag = 12
        pickerView.dataSource = self
        pickerView.delegate = self
        makeTextField.inputView = pickerView
        if let make = self.makeTextField.text {
            if !make.isEmpty {
                let selectedRow = VehiculeHelper.shared.carMakes().index(of: make)!
                pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
        }
    }

    func setupModelPicker() {
        let pickerView = UIPickerView.init()
        pickerView.tag = 13
        pickerView.dataSource = self
        pickerView.delegate = self
        modelTextField.inputView = pickerView
        if let model = self.modelTextField.text, let make = self.makeTextField.text {
            if !model.isEmpty {
                let selectedRow = VehiculeHelper.shared.carModels(make).index(of: model)!
                pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
        }
    }

    func setupColorPicker() {
        let pickerView = UIPickerView.init()
        pickerView.tag = 14
        pickerView.dataSource = self
        pickerView.delegate = self
        colorTextField.inputView = pickerView
        if let color = self.colorTextField.text {
            if !color.isEmpty {
                let selectedRow = VehiculeHelper.vehiculeColors.index(of: color)!
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
            return AppState.provinces.count
        case 12:
            return VehiculeHelper.shared.carMakes().count
        case 13:
            return VehiculeHelper.shared.carModels(makeTextField.text!).count
        case 14:
            return VehiculeHelper.vehiculeColors.count
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
            return AppState.provinces[row]
        case 12:
            return VehiculeHelper.shared.carMakes()[row]
        case 13:
            return VehiculeHelper.shared.carModels(makeTextField.text!)[row]
        case 14:
            return VehiculeHelper.vehiculeColors[row]
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
            self.provinceTextField.text = AppState.provinces[row]
            break
        case 12:
            self.makeTextField.text = VehiculeHelper.shared.carMakes()[row]
        case 13:
            self.modelTextField.text = VehiculeHelper.shared.carModels(makeTextField.text!)[row]
        case 14:
            self.colorTextField.text = VehiculeHelper.vehiculeColors[row]
        default:
            break
        }
    }
}
