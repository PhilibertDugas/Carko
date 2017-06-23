//
//  ReservationsTableViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-23.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class ReservationsTableViewController: UITableViewController {
    fileprivate var reservations: [(Reservation?)] = []

    @IBAction func OnClosePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = true
        self.tableView.tableFooterView = UIView.init()
        self.fetchReservations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchReservations()
    }
    
    fileprivate func updateBackgroundImage() {
        if reservations.count == 0 {
            self.tableView.backgroundView = (Bundle.main.loadNibNamed("HistoryEmpty", owner: self, options: nil)?[0] as! UIView)
        }
        else {
            self.tableView.backgroundView = nil
        }
    }

    fileprivate func fetchReservations() {
        Reservation.getCustomerReservations { (reservations, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else {
                self.reservations = reservations
                self.tableView.reloadData()
                self.updateBackgroundImage()
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
        cell.reservation = reservations[indexPath.row]
        return cell
    }
}
