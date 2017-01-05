//
//  NewAvailabilityViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Foundation


class NewAvailabilityViewController: UIViewController {

    @IBOutlet var mondayButton: UIButton!
    @IBOutlet weak var permanentAvailabilitySwitch: UISwitch!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var availabilitySelectionView: UIView!

    weak var delegate: ParkingAvailabilityDelegate? = nil
    var availability: AvailabilityInfo!
    var dateFormatter: DateFormatter?

    @IBAction func saveChange(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
        delegate?.userDidChangeAvailability(value: availability)
    }

    @IBAction func permanentAvailabilityToggle(_ sender: UISwitch) {
        if sender.isOn {
            availability.alwaysAvailable = true
        } else {
            availability.alwaysAvailable = false
        }
        availabilitySelectionView.isHidden = availability.alwaysAvailable
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
            availability.startTime = newTime
        } else if sender == toTextField {
            availability.stopTime = newTime
        }
    }

    @IBAction func dayToggle(_ sender: UIButton) {
        let dayId = sender.tag
        let newAvailability = !availability.daysAvailable[dayId]
        availability.daysAvailable[dayId] = newAvailability
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
        permanentAvailabilitySwitch.isOn = availability.alwaysAvailable
        availabilitySelectionView.isHidden = availability.alwaysAvailable

        let daysAvailable = availability.daysAvailable

        // findDayButton with tag=0 returns every other views. Creating a mondayButton reference is easier than changing the tag for every view in the scene
        updateButton(isOn: daysAvailable[0], button: mondayButton)

        for index in 1...6 {
            updateButton(isOn: daysAvailable[index], button: findDayButton(tag: index))
        }

        fromTextField.text = availability.startTime
        toTextField.text = availability.stopTime
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
