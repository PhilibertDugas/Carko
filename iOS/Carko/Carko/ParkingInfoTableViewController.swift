//
//  ParkingInfoTableViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class ParkingInfoTableViewController: UITableViewController {

    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var postalAddressLabel: UILabel!
    @IBOutlet weak var timeOfDayLabel: UILabel!
    @IBOutlet weak var daysAvailableLabel: UILabel!
    @IBOutlet weak var parkingRate: UILabel!
    @IBOutlet weak var parkingDescriptionLabel: UILabel!
    
    var parkingInfo: Parking?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        initializeInfo()
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
        
        if segue.identifier == "ChangeRate" {
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

extension ParkingInfoTableViewController: ParkingRateDelegate {
    func userDidChangeRate(value: Float) {
        parkingInfo?.price = value
    }
}

extension ParkingInfoTableViewController: ParkingDescriptionDelegate {
    func userDidChangeDescription(value: String) {
        parkingInfo?.parkingDescription = value
    }
}

extension ParkingInfoTableViewController: ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: ParkingAvailabilityInfo) {
        parkingInfo?.availabilityInfo = value
    }
}
