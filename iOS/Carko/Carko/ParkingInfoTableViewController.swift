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
        timeOfDayLabel.text = lapsOfTimeText(startTime: (parkingInfo?.startTime)!, endTime: (parkingInfo?.stopTime)!)
        daysAvailableLabel.text = daysEnumerationText(monday: (parkingInfo?.isMonday)!, tuesday: (parkingInfo?.isTuesday)!, wednesday: (parkingInfo?.isWednesday)!, thursday: (parkingInfo?.isThursday)!, friday: (parkingInfo?.isFriday)!, saturday: (parkingInfo?.isSaturday)!, sunday: (parkingInfo?.isSunday)!)
        
        parkingRate.text = parkingInfo!.price.asLocaleCurrency
    }
    
    func lapsOfTimeText(startTime: String, endTime: String) -> String
    {
        if parkingInfo?.startTime == "0:00 AM" && parkingInfo?.startTime == "12:00 PM"
        {
            return "All Day"
        }
        else
        {
            return ((parkingInfo?.startTime)! + "-" + (parkingInfo?.stopTime)!)
        }
    }
    
    func daysEnumerationText(monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool) -> String{
        var enumerationText = ""
        var needsPunctuation = false
        
        if monday && tuesday && wednesday && thursday && friday && saturday && sunday
        {
            return "Everyday"
        }
        
        if monday
        {
            enumerationText += "Mon"
            needsPunctuation = true
        }
        
        if tuesday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Tue"
            needsPunctuation = true
        }
        
        if wednesday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Wed"
            needsPunctuation = true
        }
        
        if thursday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Thr"
            needsPunctuation = true
        }
        
        if friday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Fri"
            needsPunctuation = true
        }
        
        if saturday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Sat"
            needsPunctuation = true
        }
        
        if sunday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Sun"
            needsPunctuation = true
        }
        
        return enumerationText
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
            destinationVC.parkingDescription = parkingInfo!.description
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
        
    }
}
