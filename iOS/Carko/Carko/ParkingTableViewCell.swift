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
    @IBOutlet weak var daysAvailable: UILabel!
    @IBOutlet var parkingImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
