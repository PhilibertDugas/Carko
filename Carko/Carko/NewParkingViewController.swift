//
//  NewParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-07.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import CoreLocation

class NewParkingViewController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createParking" {
            let vc = segue.destination as! LocationViewController
            vc.parking = Parking.init(latitude: CLLocationDegrees.init(75),
                                      longitude: CLLocationDegrees.init(-135),
                                      photoURL: URL.init(string: ""),
                                      address: "Select a location",
                                      price: 1.0,
                                      pDescription: "",
                                      isAvailable: true,
                                      availabilityInfo: AvailabilityInfo.init(),
                                      customerId: AppState.shared.customer.id)
            vc.newParking = true
        }
    }
}
