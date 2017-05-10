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

class ListParkingViewController: UIViewController {
    
    @IBOutlet var parkingTableView: UITableView!
    @IBOutlet weak var addParkingButton: RoundedCornerButton!
    
    var parkingList = [Parking]()
    var isEditingAvailability = false
    var selectedRowIndex = 0

    @IBAction func onClosePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchParkings), name: Notification.Name.init(rawValue: "NewParking"), object: nil)

        fetchParkings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.cachedCustomerParkings().count > 0 {
            updateTable(AppState.shared.cachedCustomerParkings())
        } else {
            self.setupFirstParkingView()
        }
    }

    
    func fetchParkings() {
        Parking.getCustomerParkings { (parkings, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if parkings.count > 0 {
                AppState.shared.cacheCustomerParkings(parkings)
                self.updateTable(parkings)
            } else {
                self.setupFirstParkingView()
            }
        }
    }

    func updateTable(_ parkings: [(Parking)]) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.editButtonItem.action = #selector(self.setTableEditMode)
        self.setEditing(false, animated: true)
        self.parkingTableView.setEditing(false, animated: true)
        self.removeFirstParkingView()
        self.parkingList = parkings
        self.parkingTableView.reloadData()
    }

    func setTableEditMode() {
        self.parkingTableView.setEditing(!self.parkingTableView.isEditing, animated: true)
        self.setEditing(!self.isEditing, animated: true)
    }

    func removeFirstParkingView() {
        parkingTableView.backgroundView = nil
        addParkingButton.setTitle("Add", for: .normal)
    }

    func setupFirstParkingView() {
        parkingTableView.backgroundView = NewParkingView()
        addParkingButton.setTitle("Get Started", for: .normal)
    }

    func newParkingTapped() {
        self.performSegue(withIdentifier: "newParking", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "showParkingInfo" {
            let destinationVC = segue.destination as! ParkingInfoViewController
            destinationVC.parking = parkingList[selectedRowIndex]
        } else if segue.identifier == "newParking" {
            let vc = segue.destination as! LocationViewController
            vc.parking = Parking.init()
            vc.newParking = true
        }
    }
}

extension ListParkingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRowIndex = indexPath.row
        return indexPath
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let parking = parkingList[indexPath.row]
            if parking.isAvailable {
                parking.delete(complete: completeParkingDelete)
            } else {
                super.displayDestructiveMessage("YOUR PARKING IS CURRENTLY IN USE, ARE YOU SURE YOU WANT TO REMOVE IT?", title: "PARKING IN USE", handle: { (action) in
                    parking.delete(complete: self.completeParkingDelete)
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parkingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            self.fetchParkings()
        }
    }
}
