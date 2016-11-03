//
//  NewParkingScheduleViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-22.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class NewParkingScheduleViewController: UIViewController {

    var newParking: Parking!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "newParkingSchedule" {
            let destinationViewController = segue.destination as! ParkingAvailabilityViewController
            destinationViewController.parkingAvailability = self.newParking?.availabilityInfo
            destinationViewController.delegate = self
        } else if segue.identifier! == "nextToRatesTapped" {
            let destinationViewController = segue.destination as! NewParkingRatesViewController
            destinationViewController.newParking = newParking
        }
    }
}

// Parking delegates

extension NewParkingScheduleViewController: ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: ParkingAvailabilityInfo) {
        newParking?.availabilityInfo = value
    }
}
