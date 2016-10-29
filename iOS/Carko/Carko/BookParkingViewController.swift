//
//  BookParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-20.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class BookParkingViewController: UIViewController {

    var selectedParking: Parking!
    
    @IBOutlet var addressLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = selectedParking.address
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "didTapContinue" {
            let destinationViewController = segue.destination as! ConfirmParkingViewController
            destinationViewController.parking = selectedParking
        }
    }
}
