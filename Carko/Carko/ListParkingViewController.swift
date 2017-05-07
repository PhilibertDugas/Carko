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
    var parkingList = [Parking]()
    var isEditingAvailability = false
    var selectedRowIndex = 0

    @IBAction func navigationMenuPressed(_ sender: Any) {
        self.revealViewController().revealToggle(self)
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
        self.navigationController?.navigationBar.isHidden = false
        self.removeFirstParkingView()
        self.parkingList = parkings
        self.parkingTableView.reloadData()
    }

    func removeFirstParkingView() {
        for view in self.view.subviews {
            if let firstView = view as? NewParkingView {
                firstView.removeFromSuperview()
            }
        }
    }

    func setupFirstParkingView() {
        self.navigationController?.navigationBar.isHidden = true
        let firstParkingView = NewParkingView.init(frame: self.view.frame)
        firstParkingView.mainActionButton.addTarget(self, action: #selector(self.newParkingTapped), for: UIControlEvents.touchUpInside)
        self.view.addSubview(firstParkingView)
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

extension ListParkingViewController: SWRevealViewControllerDelegate {

    fileprivate func setupSidebar() {
        let revealViewController = self.revealViewController()
        revealViewController?.delegate = self
        revealViewController?.bounceBackOnOverdraw = true
        revealViewController?.stableDragOnOverdraw = false
        revealViewController?.toggleAnimationType = .spring
        revealViewController?.rearViewRevealDisplacement = 44
        revealViewController?.rearViewRevealOverdraw = 10
        revealViewController?.rearViewRevealWidth = 300
    }
}
