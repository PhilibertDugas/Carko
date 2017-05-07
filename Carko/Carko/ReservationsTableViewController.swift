//
//  ReservationsTableViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-23.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class ReservationsTableViewController: UITableViewController {
    fileprivate var reservations: [(Reservation)] = []

    @IBAction func menuTapped(_ sender: Any) {
        self.revealViewController().revealToggle(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.fetchReservations()
        self.setupSidebar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchReservations()
    }

    fileprivate func fetchReservations() {
        Reservation.getCustomerReservations { (reservations, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else {
                self.reservations = reservations
                self.tableView.reloadData()
            }
        }
    }
}

extension ReservationsTableViewController: SWRevealViewControllerDelegate {
    fileprivate func setupSidebar() {
        let revealViewController = self.revealViewController()
        revealViewController?.delegate = self
        AppState.setupRevealViewController(revealViewController!)
        self.view.addGestureRecognizer((revealViewController?.panGestureRecognizer())!)
    }
}

extension ReservationsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath) as! ReservationTableViewCell
        cell.reservation = reservations[indexPath.row]
        return cell
    }
}
