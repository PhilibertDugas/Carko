//
//  ReservationCollectionViewCell.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-05.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import MapKit

class ReservationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var label: UILabel!
    @IBOutlet var imageViewHeightLayoutConstraint: NSLayoutConstraint!

    var reservation: Reservation? {
        didSet {
            if let reservation = reservation {
                // FIXME
                // label.text = reservation.label
                label.text = "ACTIVE RESERVATION"
            }
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? ApyaLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
}
