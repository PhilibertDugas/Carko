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

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingFetched), name: NSNotification.Name(rawValue: "parkingFetched"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: NSNotification.Name(rawValue: "parkingListUpdated"), object: nil)
        Parking.getAllParkings()
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
    
    ///////// Observers

    func parkingFetched(_ notification: Notification) {
        if let parkingData = notification.userInfo as? [String: Any] {
            parkingList.removeAll()
            for (_, parkingInstance) in parkingData {
                let parking = Parking.init(parking: parkingInstance as! [String : Any])
                parkingList.append(parking)
            }
            
            ParkingTableView.reloadData()
        }
    }
    
    func parkingListUpdate() {
        Parking.getAllParkings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self)
        
        if segue.identifier == "showParkingInfo" {
            // get a reference to the second view controller
            let destinationVC = segue.destination as! ParkingInfoTableViewController
            
            // set the parking to see
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
}
