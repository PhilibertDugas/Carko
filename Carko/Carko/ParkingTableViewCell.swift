//
//  ParkingTableViewCell.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class ParkingTableViewCell: UITableViewCell {
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet var parkingImage: UIImageView!
    @IBOutlet var priceLabel: UILabel!
}
