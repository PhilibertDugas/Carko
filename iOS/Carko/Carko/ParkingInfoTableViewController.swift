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
    
    var parkingInfo: Parking?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeInfo()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeInfo()
    {
        streetAddressLabel.text = parkingInfo?.address
        postalAddressLabel.text = parkingInfo?.address
        
        var timeOfDay:String
        if parkingInfo?.startTime == "0:00 AM" && parkingInfo?.startTime == "12:00 PM"
        {
            timeOfDay = "All Day"
        }
        else
        {
            timeOfDay = ((parkingInfo?.startTime)! + "-" + (parkingInfo?.stopTime)!)
        }
        
        timeOfDayLabel.text = timeOfDay
        parkingRate.text = parkingInfo!.price.asLocaleCurrency
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        NotificationCenter.default.removeObserver(self)
        
        if segue.identifier == "ChangeRate"
        {
            // get a reference to the second view controller
            let destinationVC = segue.destination as! ParkingRatesViewController
            
            // set the rate of the parking
            destinationVC.initialRate = parkingInfo!.price
            destinationVC.delegate = self
        }
        else if segue.identifier == "ChangeDescription"
        {
            // get a reference to the second view controller
            let destinationVC = segue.destination as! ParkingRatesViewController
            
            // set the parking to see
            //destinationVC.initialRate = parkingInfo!.price
            destinationVC.delegate = self
        }
        else if segue.identifier == "ChangeAvailability"
        {
            // get a reference to the second view controller
            let destinationVC = segue.destination as! ParkingRatesViewController
            
            // set the parking to see
            destinationVC.initialRate = parkingInfo!.price
            destinationVC.delegate = self
        }
    }
}

extension ParkingInfoTableViewController: ParkingRateDelegate
{
    func userDidChangeRate(value: Float)
    {
        parkingInfo?.price = value
    }
}

extension ParkingInfoTableViewController: ParkingDescriptionDelegate
{
    func userDidChangeDescription(value: String)
    {
        
    }
}
