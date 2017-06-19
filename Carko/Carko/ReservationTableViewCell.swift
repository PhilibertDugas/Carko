//
//  ReservationTableViewCell.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-23.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class ReservationTableViewCell: UITableViewCell {

    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var reservationLabel: UILabel!
    @IBOutlet var reservationTime: UILabel!
    @IBOutlet var reservationPrice: UILabel!

    var reservation: Reservation? {
        didSet {
            if let reservation = reservation {
                self.reservationLabel.text = reservation.event.label
                self.reservationPrice.text = reservation.totalCost.asLocaleCurrency
                self.reservationTime.text = reservation.startTime.formattedDays
                if let url = reservation.event.photoURL {
                    let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
                    eventImage.sd_setImage(with: imageReference)
                    eventImage.layer.cornerRadius = 10
                    eventImage.clipsToBounds = true
                }

            }
        }
    }
}
