//
//  ShareViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class MyParkingsViewController: UIViewController {

    @IBOutlet weak var ParkingTableView: UITableView!
    @IBOutlet weak var Edit: UIBarButtonItem!
    @IBOutlet weak var AddButton: UIBarButtonItem!
    
    var parkingList = [Parking]()
    var isEditingAvailability = false
    var selectedRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ParkingTableView.delegate = self
        ParkingTableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingFetched), name: Notification.Name.init(rawValue: "CustomerParkingFetched"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "NewParking"), object: nil)
        
        parkingListUpdate()
    }
    
    @IBAction func editingParking(_ sender: AnyObject) {
        if !isEditingAvailability {
            Edit.title = "Done"
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
            isEditingAvailability = true
            ParkingTableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
        } else {
            Edit.title = "Edit"
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
            isEditingAvailability = false
            ParkingTableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
        }
    }

    func parkingFetched(_ notification: Notification) {
        if let parkingData = notification.userInfo as? [String: Any] {
            parkingList.removeAll()
            
            let parkings = parkingData["data"] as! [(Parking)]
            for (parking) in parkings {
                parkingList.append(parking)
            }
            
            ParkingTableView.reloadData()
        }
    }
    
    func parkingListUpdate() {
        Parking.getCustomerParkings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "showParkingInfo" {
            let destinationVC = segue.destination as! ParkingInfoTableViewController
            destinationVC.parkingInfo = parkingList[selectedRowIndex]
        }
    }
}

extension MyParkingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRowIndex = indexPath.row
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ParkingTableView.dequeueReusableCell(withIdentifier: "parkingCell", for: indexPath) as! ParkingTableViewCell
        
        cell.address.text = parkingList[indexPath.row].address
        
        if !isEditingAvailability {
            cell.availabilitySwitch.isHidden = true
        }
        else {
            cell.availabilitySwitch.isHidden = false
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.parkingList.remove(at: indexPath.row)
        }
    }
}
