//
//  AvailabilityInfoTableViewCell.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-08-09.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class AvailabilityInfoTableViewCell: UITableViewCell {
    @IBOutlet var daysAvailableLabel: UILabel!
    @IBOutlet var hoursAvailableLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    var info: ParkingAvailabilityInfo? {
        didSet {
            if let info = info {
                // TODO: Fix this
                // self.daysAvailableLabel = info.mondayAvailable
                //

            }
        }
    }
}
