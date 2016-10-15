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
        timeOfDayLabel.text = parkingInfo?.lapsOfTimeText()
        daysAvailableLabel.text = parkingInfo?.daysEnumerationText()
        
        parkingRate.text = parkingInfo!.price.asLocaleCurrency
        parkingDescriptionLabel.text = parkingInfo?.parkingDescription
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
            destinationVC.parkingRate = parkingInfo!.price
            destinationVC.delegate = self
        }
        else if segue.identifier == "ChangeDescription"
        {
            // get a reference to the second view controller
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            
            // set the parking to see
            destinationVC.parkingDescription = parkingInfo!.parkingDescription
            destinationVC.delegate = self
        }
        else if segue.identifier == "ChangeAvailability"
        {
            // get a reference to the second view controller
            let destinationVC = segue.destination as! ParkingAvailabilityViewController
            
            // set the parking to see
            let parkingAvailabilityInfo = ParkingAvailabilityInfo(alwaysAvailable: parkingInfo!.alwaysAvailable, startTime: parkingInfo!.startTime, stopTime: parkingInfo!.stopTime, isMonday: parkingInfo!.isMonday, isTuesday: parkingInfo!.isTuesday, isWednesday: parkingInfo!.isWednesday, isThursday: parkingInfo!.isThursday, isFriday: parkingInfo!.isFriday, isSaturday: parkingInfo!.isSaturday, isSunday: parkingInfo!.isSunday)
            
            destinationVC.parkingAvailability = parkingAvailabilityInfo
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
        parkingInfo?.parkingDescription = value
    }
}

extension ParkingInfoTableViewController: ParkingAvailabilityDelegate
{
    func userDidChangeAvailability(value: ParkingAvailabilityInfo)
    {
        parkingInfo?.alwaysAvailable = value.alwaysAvailable
        
        parkingInfo?.startTime = value.startTime
        parkingInfo?.stopTime = value.stopTime
        
        parkingInfo?.isMonday = value.isMonday
        parkingInfo?.isTuesday = value.isTuesday
        parkingInfo?.isWednesday = value.isWednesday
        parkingInfo?.isThursday = value.isThursday
        parkingInfo?.isFriday = value.isFriday
        parkingInfo?.isSaturday = value.isSaturday
        parkingInfo?.isSunday = value.isSunday
    }
}
