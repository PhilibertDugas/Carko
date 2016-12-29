//
//  ShareViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class MyParkingsViewController: UITableViewController {
    var parkingList = [Parking]()
    var isEditingAvailability = false
    var selectedRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingFetched), name: Notification.Name.init(rawValue: "CustomerParkingFetched"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "NewParking"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "ParkingDeleted"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        parkingListUpdate()
    }

    func parkingFetched(_ notification: Notification) {
        if let parkingData = notification.userInfo as? [String: Any] {
            parkingList.removeAll()
            
            let parkings = parkingData["data"] as! [(Parking)]
            for (parking) in parkings {
                parkingList.append(parking)
            }
            tableView.reloadData()
        }
    }
    
    func parkingListUpdate() {
        Parking.getCustomerParkings()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "showParkingInfo" {
            let destinationVC = segue.destination as! ParkingInfoViewController
            destinationVC.parking = parkingList[selectedRowIndex]
        }
    }
}

extension MyParkingsViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRowIndex = indexPath.row
        return indexPath
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let parking = parkingList[indexPath.row]
            if parking.isAvailable {
                parking.delete(complete: completeParkingDelete)
            } else {
                super.displayErrorMessage("You can't remove a parking while it's in use. Please wait after the parking duration")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parkingCell", for: indexPath) as! ParkingTableViewCell
        let parking = parkingList[indexPath.row]
        cell.address.text = parking.address
        cell.availabilityLabel.text = parking.availabilityInfo.daysEnumerationText()
        cell.priceLabel.text = "\(parking.price.asLocaleCurrency)/h"

        if let url = parking.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            cell.parkingImage.sd_setImage(with: imageReference)
        }

        return cell
    }

    func completeParkingDelete(error: Error?) {
        if let error = error {
            super.displayErrorMessage(error.localizedDescription)
        } else {
            NotificationCenter.default.post(name: Notification.Name.init("ParkingDeleted"), object: nil, userInfo: nil)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
