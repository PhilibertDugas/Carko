//
//  ParkingAvailabilityViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Foundation

protocol ParkingAvailabilityDelegate: class {
    func userDidChangeAvailability(value: ParkingAvailabilityInfo)
}

class ParkingAvailabilityViewController: UIViewController {
    
    @IBOutlet weak var permanentAvailabilitySwitch: UISwitch!
    
    @IBOutlet var daysButton: [UIButton]!
    
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBOutlet weak var availabilitySelectionView: UIView!
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ParkingAvailabilityDelegate? = nil
    var parkingAvailability: ParkingAvailabilityInfo?
    var dateFormatter: DateFormatter?
        
    @IBAction func saveChange(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        delegate?.userDidChangeAvailability(value: parkingAvailability!)
    }
    
    @IBAction func cancelChange(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func permanentAvailabilityToggle(_ sender: AnyObject) {
        updatePermanentAvailability()
    }
    
    @IBAction func fromTimeEditBegin(_ sender: AnyObject) {
        let datePicker = UIDatePicker.init()
        datePicker.datePickerMode = UIDatePickerMode.time
        fromTextField.inputView = datePicker
    }
    
    @IBAction func fromTimeEditEnd(_ sender: AnyObject) {
        let datePicker = fromTextField.inputView as! UIDatePicker
        let startTime = self.dateFormatter!.string(from: datePicker.date)
        fromTextField.text = startTime
        parkingAvailability!.startTime = startTime
    }
    
    @IBAction func toTimeEditBegin(_ sender: AnyObject) {
        let datePicker = UIDatePicker.init()
        datePicker.datePickerMode = UIDatePickerMode.time
        toTextField.inputView = datePicker
    }
    
    @IBAction func toTimeEditEnd(_ sender: AnyObject) {
        let datePicker = toTextField.inputView as! UIDatePicker
        let stopTime = self.dateFormatter!.string(from: datePicker.date)
        toTextField.text = stopTime
        parkingAvailability!.stopTime = stopTime
    }
    
    @IBAction func mondayToggle(_ sender: AnyObject) {
        parkingAvailability!.isMonday = !parkingAvailability!.isMonday
        updateButton(isOn: parkingAvailability!.isMonday, button: mondayButton)
    }
    
    @IBAction func tuesdayToggle(_ sender: AnyObject) {
        parkingAvailability!.isTuesday = !parkingAvailability!.isTuesday
        updateButton(isOn: parkingAvailability!.isTuesday, button: tuesdayButton)
    }
    
    @IBAction func wednesdayToggle(_ sender: AnyObject) {
        parkingAvailability!.isWednesday = !parkingAvailability!.isWednesday
        updateButton(isOn: parkingAvailability!.isWednesday, button: wednesdayButton)
    }
    
    @IBAction func thursdayToggle(_ sender: AnyObject) {
        parkingAvailability!.isThursday = !parkingAvailability!.isThursday
        updateButton(isOn: parkingAvailability!.isThursday, button: thursdayButton)
    }
    
    @IBAction func fridayToggle(_ sender: AnyObject) {
        parkingAvailability!.isFriday = !parkingAvailability!.isFriday
        updateButton(isOn: parkingAvailability!.isFriday, button: fridayButton)
    }
    
    @IBAction func saturdayToggle(_ sender: AnyObject) {
        parkingAvailability!.isSaturday = !parkingAvailability!.isSaturday
        updateButton(isOn: parkingAvailability!.isSaturday, button: saturdayButton)
    }
    
    @IBAction func sundayToggle(_ sender: AnyObject) {
        parkingAvailability!.isSunday = !parkingAvailability!.isSunday
        updateButton(isOn: parkingAvailability!.isSunday, button: sundayButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.dateFormatter = DateFormatter.init()
        self.dateFormatter!.dateFormat = "h:mm a"
    }

    override func viewDidAppear(_ animated: Bool) {
        updateAvailability()
    }
    
    func updateAvailability() {
        updatePermanentAvailability()
        
        updateButton(isOn: parkingAvailability!.isMonday, button: mondayButton)
        updateButton(isOn: parkingAvailability!.isTuesday, button: tuesdayButton)
        updateButton(isOn: parkingAvailability!.isWednesday, button: wednesdayButton)
        updateButton(isOn: parkingAvailability!.isThursday, button: thursdayButton)
        updateButton(isOn: parkingAvailability!.isFriday, button: fridayButton)
        updateButton(isOn: parkingAvailability!.isSaturday, button: saturdayButton)
        updateButton(isOn: parkingAvailability!.isSunday, button: sundayButton)
        
        fromTextField.text = parkingAvailability!.startTime
        toTextField.text = parkingAvailability!.stopTime
    }
    
    func updatePermanentAvailability() {
        if parkingAvailability!.alwaysAvailable {
            availabilitySelectionView.isHidden = true
        }
        else {
            availabilitySelectionView.isHidden = false
        }
    }
    
    func updateButton(isOn: Bool, button: UIButton!) {
        if isOn {
            button.backgroundColor = UIColor.green
        }
        else {
            button.backgroundColor = UIColor.clear
        }
    }
}
