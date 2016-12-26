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
    func userDidChangeAvailability(value: AvailabilityInfo)
}

class ParkingAvailabilityViewController: UIViewController {
    
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet weak var permanentAvailabilitySwitch: UISwitch!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var availabilitySelectionView: UIView!
    
    weak var delegate: ParkingAvailabilityDelegate? = nil
    var parkingAvailability: AvailabilityInfo!
    var dateFormatter: DateFormatter?
        
    @IBAction func saveChange(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
        delegate?.userDidChangeAvailability(value: parkingAvailability)
    }

    @IBAction func permanentAvailabilityToggle(_ sender: UISwitch) {
        if sender.isOn {
            parkingAvailability.alwaysAvailable = true
        } else {
            parkingAvailability.alwaysAvailable = false
        }
        availabilitySelectionView.isHidden = parkingAvailability.alwaysAvailable
    }

    @IBAction func timeEditBegin(_ sender: UITextField) {
        let datePicker = UIDatePicker.init()
        datePicker.datePickerMode = UIDatePickerMode.time
        sender.inputView = datePicker
    }

    @IBAction func timeEditEnd(_ sender: UITextField) {
        let datePicker = sender.inputView as! UIDatePicker
        let newTime = self.dateFormatter!.string(from: datePicker.date)

        sender.text = newTime
        if sender == fromTextField {
            parkingAvailability.startTime = newTime
        } else if sender == toTextField {
            parkingAvailability.stopTime = newTime
        }
    }
    
    @IBAction func dayToggle(_ sender: UIButton) {
        let dayId = sender.tag
        let newAvailability = !parkingAvailability.daysAvailable[dayId]
        parkingAvailability.daysAvailable[dayId] = newAvailability
        updateButton(isOn: newAvailability, button: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.dateFormatter = DateFormatter.init()
        self.dateFormatter!.dateFormat = "HH:mm"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAvailability()
    }
    
    func updateAvailability() {
        permanentAvailabilitySwitch.isOn = parkingAvailability.alwaysAvailable
        availabilitySelectionView.isHidden = parkingAvailability.alwaysAvailable

        let daysAvailable = parkingAvailability.daysAvailable

        // findDayButton with tag=0 returns every other views. Creating a mondayButton reference is easier than changing the tag for every view in the scene
        updateButton(isOn: daysAvailable[0], button: mondayButton)

        for index in 1...6 {
            updateButton(isOn: daysAvailable[index], button: findDayButton(tag: index))
        }
        
        fromTextField.text = parkingAvailability.startTime
        toTextField.text = parkingAvailability.stopTime
    }
    
    func updateButton(isOn: Bool, button: UIButton!) {
        if isOn {
            button.backgroundColor = UIColor.init(netHex: 0x00C441)
        }
        else {
            button.backgroundColor = UIColor.clear
        }
    }

    private func findDayButton(tag: Int) -> UIButton {
        return self.view.viewWithTag(tag) as! UIButton
    }
}
