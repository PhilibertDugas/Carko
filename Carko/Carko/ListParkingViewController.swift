//
//  ShareViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import CoreLocation

class ListParkingViewController: UITableViewController {
    var parkingList = [Parking]()
    var isEditingAvailability = false
    var selectedRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "NewParking"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "ParkingDeleted"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        parkingListUpdate()
    }

    
    func parkingListUpdate() {
        Parking.getCustomerParkings { (parkings, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else {
                if parkings.count > 0 {
                    self.navigationItem.leftBarButtonItem = self.editButtonItem
                    self.setEditing(false, animated: true)
                } else {
                    self.performSegue(withIdentifier: "firstParking", sender: nil)
                }
                self.parkingList = parkings
                self.tableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "showParkingInfo" {
            let destinationVC = segue.destination as! ParkingInfoViewController
            destinationVC.parking = parkingList[selectedRowIndex]
        } else if segue.identifier == "newParking" {
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

extension ListParkingViewController {
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
        cell.label.text = parking.address
        
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
