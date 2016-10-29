//
//  NewParkingRatesViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-22.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class NewParkingRatesViewController: UIViewController {

    var newParking: Parking!
    
    @IBAction func confirmTapped(_ sender: AnyObject) {
        newParking?.persist()
        NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "newParkingRates" {
            let destinationViewController = segue.destination as! ParkingRatesViewController
            destinationViewController.parkingRate = self.newParking.price
            destinationViewController.delegate = self
        } else if segue.identifier! == "nextToRatesTapped" {
            let destinationViewController = segue.destination as! NewParkingRatesViewController
            destinationViewController.newParking = newParking
        }
    }
}

extension NewParkingRatesViewController: ParkingRateDelegate {
    func userDidChangeRate(value: Float) {
        newParking?.price = value
    }
}

