//
//  ParkingRatesViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

protocol ParkingRateDelegate: class {
    func userDidChangeRate(value: Float)
}

class ParkingRatesViewController: UIViewController {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ParkingRateDelegate? = nil
    
    @IBOutlet weak var postedRateField: UITextField!
    @IBOutlet weak var hourlyRateField: UITextField!
    @IBOutlet weak var postedRateSlider: UISlider!
    
    let appPercentageCut:Float = 0.2
    var parkingRate: Float?
    
    @IBAction func postedRateSliderChanged(_ sender: AnyObject) {
        parkingRate = Float(postedRateSlider.value).asCurrency
        ratesUpdated()
    }
    
    @IBAction func saveChange(_ sender: AnyObject) {
        let rates = Float(postedRateSlider.value).asCurrency
        let _ = self.navigationController?.popViewController(animated: true)
        delegate?.userDidChangeRate(value: rates)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let rate = parkingRate {
            postedRateSlider.value = rate
            ratesUpdated()
        }
    }
    
    func ratesUpdated() {
        postedRateField.text = "\(parkingRate!)"
        hourlyRateField.text = "\((parkingRate! * (1 - appPercentageCut)))"
    }
}

extension ParkingRatesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // allow backspace
        if (string.characters.count == 0) {
            return true
        }
        
        if (Int(string) != nil) {
            return true
        }
        
        return false
    }
}
