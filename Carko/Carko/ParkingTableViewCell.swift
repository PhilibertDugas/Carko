//
//  ParkingTableViewCell.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class ParkingTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var parkingImage: UIImageView!
    @IBOutlet var revenueLabel: UILabel!
    @IBOutlet var notListedLabel: UILabel!
    @IBOutlet var totalEarnedLabel: UILabel!

    var parking: Parking? {
        didSet {
            if let parking = parking {
                label.text = parking.address
                if parking.totalRevenue > 0.0 {
                    revenueLabel.text = parking.totalRevenue.asLocaleCurrency
                    totalEarnedLabel.isHidden = false
                } else {
                    revenueLabel.isHidden = true
                    totalEarnedLabel.isHidden = true
                }

                if parking.isComplete {
                    notListedLabel.isHidden = true
                } else {
                    notListedLabel.isHidden = false
                }

                if let url = parking.photoURL {
                    ImageLoaderHelper.loadImageFromUrl(parkingImage, url: url)
                }
            }
        }
    }
}
