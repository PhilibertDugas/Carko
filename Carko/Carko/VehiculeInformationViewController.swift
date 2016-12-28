//
//  VehiculeInformationViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class VehiculeInformationViewController: UIViewController {
    @IBOutlet var licensePlateTextField: UnderlineTextField!
    @IBOutlet var makeTextField: UnderlineTextField!
    @IBOutlet var modelTextField: UnderlineTextField!
    @IBOutlet var yearTextField: UnderlineTextField!
    @IBOutlet var colorTextField: UnderlineTextField!
    @IBOutlet var provinceTextField: UnderlineTextField!

    @IBAction func okTapped(_ sender: Any) {
        if let licensePlate = licensePlateTextField.text, let make = makeTextField.text, let model = modelTextField.text, let year = yearTextField.text, let color = colorTextField.text, let province = provinceTextField.text {
            let vehicule = Vehicule.init(license: licensePlate, make: make, model: model, year: year, color: color, province: province)
            vehicule.persist(completion: { (error) in
                if let error = error {
                    super.displayErrorMessage(error.localizedDescription)
                } else {
                    AppState.shared.customer.vehicule = vehicule
                    let _  = self.navigationController?.popToRootViewController(animated: true)
                }
            })
        } else {
            super.displayErrorMessage("BRUH")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
}
