//
//  NewRatesViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class NewRatesViewController: UIViewController {

    weak var delegate: ParkingRateDelegate? = nil

    @IBOutlet var postedRateField: UITextField!
    @IBOutlet var hourlyRateField: UITextField!
    @IBOutlet var postedRateSlider: UISlider!

    let appPercentageCut:Float = 0.2
    var parkingRate: Float?

    @IBAction func postedRateSliderChanged(_ sender: AnyObject) {
        parkingRate = Float(postedRateSlider.value).asCurrency
        ratesUpdated()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        super.hideKeyboardWhenTappedAround()

        if let rate = parkingRate {
            postedRateSlider.value = rate
            ratesUpdated()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushAvailability" {
            let vc = segue.destination as! NewAvailabilityViewController
            vc.availability = AvailabilityInfo.init()
        }
    }

    func ratesUpdated() {
        postedRateField.text = "\(parkingRate!)"
        hourlyRateField.text = "\((parkingRate! * (1 - appPercentageCut)))"
    }
}
