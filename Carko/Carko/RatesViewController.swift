//
//  NewRatesViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

protocol ParkingRateDelegate {
    func userDidChangeRate(value: Float)
}

class RatesViewController: UIViewController {

    @IBOutlet var postedRateField: UITextField!
    @IBOutlet var hourlyRateField: UITextField!
    @IBOutlet var postedRateSlider: UISlider!
    @IBOutlet var progressView: UIView!

    var delegate: ParkingRateDelegate?

    let appPercentageCut:Float = 0.2
    var parkingRate: Float!
    var parking: Parking!
    var newParking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if !newParking {
            progressView.isHidden = true
        }

        parkingRate = parking.price
        postedRateSlider.value = parkingRate
        ratesUpdated()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushAvailability" {
            let vc = segue.destination as! AvailabilityViewController
            vc.parking = parking
            vc.newParking = true
        }
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        parking.price = parkingRate!
        if newParking {
            self.performSegue(withIdentifier: "pushAvailability", sender: nil)
        } else {
            delegate?.userDidChangeRate(value: parking.price)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func postedRateSliderChanged(_ sender: AnyObject) {
        parkingRate = Float(postedRateSlider.value).asCurrency
        ratesUpdated()
    }

    func ratesUpdated() {
        postedRateField.text = "\(parkingRate!)"
        hourlyRateField.text = "\((parkingRate! * (1 - appPercentageCut)))"
    }
}
