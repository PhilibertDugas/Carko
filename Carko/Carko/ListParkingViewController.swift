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

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableHeaderView = UIView.init(frame: (self.navigationController?.navigationBar.frame)!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.parkingAdded), name: Notification.Name.init(rawValue: "NewParking"), object: nil)

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

    func parkingAdded() {
        self.tableView.isScrollEnabled = true
        self.tableView.tableFooterView?.isHidden = false
        self.fetchParkings()
    }

    func fetchParkings() {
        Parking.getCustomerParkings { (parkings, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if parkings.count > 0 {
                AppState.shared.cacheCustomerParkings(parkings)
                self.updateTable(parkings)
            } else {
                self.parkingList.removeAll()
                self.tableView.reloadData()
                self.setupFirstParkingView()
            }
        }
    }

    func updateTable(_ parkings: [(Parking)]) {
        self.navigationController?.navigationBar.isHidden = false
        self.removeFirstParkingView()
        self.parkingList = parkings
        self.tableView.reloadData()
    }

    func removeFirstParkingView() {
        self.tableView.tableFooterView?.isHidden = false

        tableView.backgroundView = nil
        self.tableView.isScrollEnabled = true
    }

    func setupFirstParkingView() {
        self.tableView.tableFooterView?.isHidden = true

        let firstParkingView = NewParkingView.init()
        firstParkingView.mainActionButton.addTarget(self, action: #selector(self.newParkingTapped), for: UIControlEvents.touchUpInside)

        self.tableView.backgroundView = firstParkingView
        self.tableView.isScrollEnabled = false
    }

    func newParkingTapped() {
        self.performSegue(withIdentifier: "newParking", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "showParkingInfo" {
            let destinationVC = segue.destination as! ParkingInfoViewController
            destinationVC.parking = parkingList[selectedRowIndex]
            destinationVC.deleteDelegate = self
        } else if segue.identifier == "newParking" {
            let vc = segue.destination as! LocationViewController
            vc.parking = Parking.init()
            vc.newParking = true
        }
    }
}

extension ListParkingViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRowIndex = indexPath.row
        return indexPath
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
}

extension ListParkingViewController: ParkingDeleteDelegate {
    func parkingDeleted() {
        self.fetchParkings()
    }
}
