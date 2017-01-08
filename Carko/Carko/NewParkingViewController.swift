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
            vc.parking = Parking.init()
            vc.newParking = true
        }
    }
}
