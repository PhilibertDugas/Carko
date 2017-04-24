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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init()
        self.fetchReservations()
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

extension ReservationsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCell", for: indexPath) as! ReservationTableViewCell

        let reservation = reservations[indexPath.row]

        cell.reservationLabel.text = reservation.label
        cell.reservationPrice.text = reservation.totalCost.asLocaleCurrency
        cell.reservationTime.text = "From \(reservation.startTime.formattedDays)"
        
        return cell
    }
}
