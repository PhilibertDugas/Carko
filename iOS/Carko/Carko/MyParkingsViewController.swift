//
//  ShareViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class MyParkingsViewController: UIViewController {

    @IBOutlet weak var ParkingTableView: UITableView!
    
    var parkingList = [Parking]()
    var isEditingAvailability = false
    var selectedRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Parkings"

        ParkingTableView.delegate = self
        ParkingTableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingFetched), name: Notification.Name.init(rawValue: "CustomerParkingFetched"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "NewParking"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingListUpdate), name: Notification.Name.init(rawValue: "ParkingDeleted"), object: nil)

        parkingListUpdate()
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
            let destinationVC = segue.destination as! ParkingInfoViewController
            destinationVC.parking = parkingList[selectedRowIndex]
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

        if let url = parkingList[indexPath.row].photoURL {
            let imageReference = AppState.sharedInstance.storageReference.storage.reference(forURL: url.absoluteString)
            cell.parkingImage.sd_setImage(with: imageReference)
        }

        return cell
    }
}
