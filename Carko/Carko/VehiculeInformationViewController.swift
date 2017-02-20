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

        if let vehicule = AppState.shared.customer.vehicule {
            licensePlateTextField.text = vehicule.license
            makeTextField.text = vehicule.make
            modelTextField.text = vehicule.model
            yearTextField.text = vehicule.year
            colorTextField.text = vehicule.color
            provinceTextField.text = vehicule.province
        }

        licensePlateTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        makeTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        modelTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        yearTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        colorTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
        provinceTextField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)
    }

    func displaySuccessMessage() {
        let responder = SCLAlertView.init().showSuccess(NSLocalizedString("Congratulations", comment: ""), subTitle: NSLocalizedString("You just added your vehicule", comment: ""))
        responder.setDismissBlock {
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
