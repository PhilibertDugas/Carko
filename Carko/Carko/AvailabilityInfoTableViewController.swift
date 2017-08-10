//
//  AvailabilityInfoTableViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-08-09.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class AvailabilityInfoTableViewController: UITableViewController {

    fileprivate let cellIdentifier = "AvailabilityInfoCell"
    var infos: [(ParkingAvailabilityInfo?)] = []

    fileprivate var selectedInfo: ParkingAvailabilityInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfo" {
            // TODO: Finish
        }
    }
}

extension AvailabilityInfoTableViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AvailabilityInfoTableViewCell

        cell.info = infos[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedInfo = infos[indexPath.row]
        self.performSegue(withIdentifier: "showInfo", sender: nil)
    }

}
