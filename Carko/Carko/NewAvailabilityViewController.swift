//
//  NewAvailabilityViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Foundation
import _10Clock

class NewAvailabilityViewController: UIViewController {

    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var clock: TenClock!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!

    weak var delegate: ParkingAvailabilityDelegate? = nil
    var availability: AvailabilityInfo!
    var dateFormatter: DateFormatter!
    var parking: Parking!

    @IBAction func dayToggle(_ sender: UIButton) {
        let dayId = sender.tag
        let newAvailability = !availability.daysAvailable[dayId]
        availability.daysAvailable[dayId] = newAvailability
        updateButton(isOn: newAvailability, button: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        availability = parking.availabilityInfo
        self.hideKeyboardWhenTappedAround()
        self.dateFormatter = DateFormatter.init()
        self.dateFormatter.dateFormat = "HH:mm"
        setupClock()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAvailability()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newPhoto" {
            let vc = segue.destination as! NewPhotoViewController
            vc.parking = parking
        }
    }

    func setupClock() {
        self.clock.delegate = self
        self.clock.minorTicksEnabled = false
        self.clock.centerTextColor = UIColor.black
        // For some reasone endDate & startDate are reversed
        self.clock.endDate = self.availability.startDate()
        self.clock.startDate = self.availability.stopDate()
    }

    func updateAvailability() {
        let daysAvailable = availability.daysAvailable

        // findDayButton with tag=0 returns every other views. Creating a mondayButton reference is easier than changing the tag for every view in the scene
        updateButton(isOn: daysAvailable[0], button: mondayButton)

        for index in 1...6 {
            updateButton(isOn: daysAvailable[index], button: findDayButton(tag: index))
        }

        updateTimeLabel(startTime: availability.startTime, endTime: availability.stopTime)
    }

    func updateTimeLabel(startTime: String, endTime: String) {
        fromLabel.text = startTime
        toLabel.text = endTime
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

extension NewAvailabilityViewController: TenClockDelegate {
    func timesChanged(_ clock: TenClock, startDate: Date, endDate: Date) {
        let startTime = dateFormatter.string(from: endDate)
        let stopTime = dateFormatter.string(from: startDate)
        availability.startTime = startTime
        availability.stopTime = stopTime
    }

    func timesUpdated(_ clock: TenClock, startDate: Date, endDate: Date) {
        // For some reason, startDate & endDate are reversed
        let startTime = dateFormatter.string(from: endDate)
        let stopTime = dateFormatter.string(from: startDate)
        updateTimeLabel(startTime: startTime, endTime: stopTime)
    }
}
