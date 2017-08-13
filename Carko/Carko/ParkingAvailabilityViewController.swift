//
//  ParkingAvailabilityViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-08-12.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

protocol ParkingAvailabilityInfoDelegate {
    func userDidChangeAvailability(value: ParkingAvailabilityInfo)
}


class ParkingAvailabilityViewController: UIViewController {
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var tuesdayButton: UIButton!
    @IBOutlet var wednesdayButton: UIButton!
    @IBOutlet var thursdayButton: UIButton!
    @IBOutlet var fridayButton: UIButton!
    @IBOutlet var saturdayButton: UIButton!
    @IBOutlet var sundayButton: UIButton!

    @IBOutlet var fromTextField: UITextField!
    @IBOutlet var toTextField: UITextField!

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceSlider: UISlider!
    @IBOutlet var mainButton: SmallRoundedCornerButton!

    var parking: Parking!
    var parkingAvailabilityInfo: ParkingAvailabilityInfo!
    var newParking: Bool = false
    var delegate: ParkingAvailabilityInfoDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = true
        if self.newParking {
            self.mainButton.isHidden = false
        } else {
            self.mainButton.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let info = parking.parkingAvailabilityInfo.first {
            parkingAvailabilityInfo = info
        } else {
            parkingAvailabilityInfo = ParkingAvailabilityInfo.init()
        }

        initializeButtons()
        initializeTimeFields()
        initializePrice()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !newParking {
            delegate?.userDidChangeAvailability(value: parkingAvailabilityInfo)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushPhoto" {
            let vc = segue.destination as! NewPhotoViewController
            vc.parking = parking
        }
    }

    @IBAction func dayPressed(_ sender: UIButton) {
        var newAvailability = false
        switch sender.tag {
        case 10:
            parkingAvailabilityInfo.mondayAvailable = !parkingAvailabilityInfo.mondayAvailable
            newAvailability = parkingAvailabilityInfo.mondayAvailable
            break
        case 11:
            parkingAvailabilityInfo.tuesdayAvailable = !parkingAvailabilityInfo.tuesdayAvailable
            newAvailability = parkingAvailabilityInfo.tuesdayAvailable
            break
        case 12:
            parkingAvailabilityInfo.wednesdayAvailable = !parkingAvailabilityInfo.wednesdayAvailable
            newAvailability = parkingAvailabilityInfo.wednesdayAvailable
            break
        case 13:
            parkingAvailabilityInfo.thursdayAvailable = !parkingAvailabilityInfo.thursdayAvailable
            newAvailability = parkingAvailabilityInfo.thursdayAvailable
            break
        case 14:
            parkingAvailabilityInfo.fridayAvailable = !parkingAvailabilityInfo.fridayAvailable
            newAvailability = parkingAvailabilityInfo.fridayAvailable
            break
        case 15:
            parkingAvailabilityInfo.saturdayAvailable = !parkingAvailabilityInfo.saturdayAvailable
            newAvailability = parkingAvailabilityInfo.saturdayAvailable
            break
        case 16:
            parkingAvailabilityInfo.sundayAvailable = !parkingAvailabilityInfo.sundayAvailable
            newAvailability = parkingAvailabilityInfo.sundayAvailable
            break
        default:
            break
        }
        setButtonState(sender, active: newAvailability)
        enableMainButton()
    }

    @IBAction func timeEditBegin(_ sender: UITextField) {
        let datePicker = UIDatePicker.init()
        datePicker.datePickerMode = UIDatePickerMode.time
        if sender == fromTextField {
            datePicker.date = DateHelper.getDateWithHour(parkingAvailabilityInfo.startHour) ?? Date.init()
        } else {
            datePicker.date = DateHelper.getDateWithHour(parkingAvailabilityInfo.stopHour) ?? Date.init()
        }
        sender.inputView = datePicker
    }

    @IBAction func timeEditEnd(_ sender: UITextField) {
        guard let datePicker = sender.inputView as? UIDatePicker else { return }
        let newTime = DateHelper.getHourString(datePicker.date)

        sender.text = newTime
        if sender == fromTextField {
            parkingAvailabilityInfo.startHour = newTime
        } else if sender == toTextField {
            parkingAvailabilityInfo.stopHour = newTime
        }
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let step: Float = 0.05
        let roundedValue = round(sender.value / step) * step

        sender.value = roundedValue
        priceLabel.text = roundedValue.asLocaleCurrency
        parkingAvailabilityInfo.price = roundedValue
    }
}

// All functions related to day buttons
extension ParkingAvailabilityViewController {
    fileprivate func initializeButtons() {
        setButtonState(mondayButton, active: parkingAvailabilityInfo.mondayAvailable)
        setButtonState(tuesdayButton, active: parkingAvailabilityInfo.tuesdayAvailable)
        setButtonState(wednesdayButton, active: parkingAvailabilityInfo.wednesdayAvailable)
        setButtonState(thursdayButton, active: parkingAvailabilityInfo.thursdayAvailable)
        setButtonState(fridayButton, active: parkingAvailabilityInfo.fridayAvailable)
        setButtonState(saturdayButton, active: parkingAvailabilityInfo.saturdayAvailable)
        setButtonState(sundayButton, active: parkingAvailabilityInfo.sundayAvailable)
        enableMainButton()
    }

    fileprivate func setButtonState(_ button: UIButton, active: Bool) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.accentColor.cgColor

        if active {
            button.backgroundColor = UIColor.accentColor
        } else {
            button.backgroundColor = UIColor.clear
        }
    }

    fileprivate func enableMainButton() {
        if parkingAvailabilityInfo.isAvailable() {
            mainButton.isEnabled = true
            mainButton.alpha = 1.00
        } else {
            mainButton.isEnabled = false
            mainButton.alpha = 0.6
        }
    }
}

// All functions related to the "from" and "to" text fields
extension ParkingAvailabilityViewController {
    fileprivate func initializeTimeFields() {
        fromTextField.text = parkingAvailabilityInfo.startHour
        toTextField.text = parkingAvailabilityInfo.stopHour
    }

}

// All functions related to the price
extension ParkingAvailabilityViewController {
    fileprivate func initializePrice() {
        priceLabel.text = parkingAvailabilityInfo.price.asLocaleCurrency
        priceSlider.value = parkingAvailabilityInfo.price
    }
}
