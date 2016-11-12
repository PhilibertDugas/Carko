//
//  ParkingInfoTableViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class ParkingInfoViewController: UIViewController {

    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var postalAddressLabel: UILabel!
    @IBOutlet weak var timeOfDayLabel: UILabel!
    @IBOutlet weak var daysAvailableLabel: UILabel!
    @IBOutlet weak var parkingRate: UILabel!
    @IBOutlet weak var parkingDescriptionLabel: UILabel!
    
    @IBOutlet var addressCollection: UIView!
    @IBOutlet var descriptionCollection: UIView!
    @IBOutlet var availabilityCollection: UIView!
    @IBOutlet var ratesCollection: UIView!
    
    var parkingInfo: Parking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        initializeInfo()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func removeParkingTapped(_ sender: Any) {
        parkingInfo?.delete()
        self.dismiss(animated: true) {
            Parking.getCustomerParkings()
        }
    }

    func setupCollectionViews() {
        let tapDescriptionGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedDescription))
        let tapAvailabilityGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedAvailability))
        let tapRatesGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedRates))
        descriptionCollection.addGestureRecognizer(tapDescriptionGesture)
        availabilityCollection.addGestureRecognizer(tapAvailabilityGesture)
        ratesCollection.addGestureRecognizer(tapRatesGesture)


        // TODO extract this in a custom UIView
        descriptionCollection.layer.borderColor = UIColor.lightGray.cgColor
        descriptionCollection.layer.borderWidth = CGFloat.init(1.0)

        availabilityCollection.layer.borderColor = UIColor.lightGray.cgColor
        availabilityCollection.layer.borderWidth = CGFloat.init(1.0)

        ratesCollection.layer.borderColor = UIColor.lightGray.cgColor
        ratesCollection.layer.borderWidth = CGFloat.init(1.0)

    }

    func tappedDescription() {
        performSegue(withIdentifier: "ChangeDescription", sender: nil)
    }

    func tappedAvailability() {
        performSegue(withIdentifier: "ChangeAvailability", sender: nil)
    }

    func tappedRates() {
        performSegue(withIdentifier: "ChangeRates", sender: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeInfo()
    }

    func initializeInfo() {
        streetAddressLabel.text = parkingInfo?.address
        postalAddressLabel.text = parkingInfo?.address

        // TODO: Not sure if this belong here
        timeOfDayLabel.text = parkingInfo?.availabilityInfo.lapsOfTimeText()
        daysAvailableLabel.text = parkingInfo?.availabilityInfo.daysEnumerationText()
        
        parkingRate.text = parkingInfo!.price.asLocaleCurrency
        parkingDescriptionLabel.text = parkingInfo?.parkingDescription
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self)
        
        if segue.identifier == "ChangeRates" {
            let destinationVC = segue.destination as! ParkingRatesViewController
            destinationVC.parkingRate = parkingInfo!.price
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parkingInfo!.parkingDescription
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeAvailability" {
            let destinationVC = segue.destination as! ParkingAvailabilityViewController
            destinationVC.parkingAvailability = parkingInfo?.availabilityInfo
            destinationVC.delegate = self
        }
    }
}

extension ParkingInfoViewController: ParkingRateDelegate {
    func userDidChangeRate(value: Float) {
        parkingInfo?.price = value
    }
}

extension ParkingInfoViewController: ParkingDescriptionDelegate {
    func userDidChangeDescription(value: String) {
        parkingInfo?.parkingDescription = value
    }
}

extension ParkingInfoViewController: ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: ParkingAvailabilityInfo) {
        parkingInfo?.availabilityInfo = value
    }
}
