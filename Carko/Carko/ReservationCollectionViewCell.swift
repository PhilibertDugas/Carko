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

    let parkingRange = CLLocationDistance.init(500)

    var reservation: Reservation? {
        didSet {
            if let reservation = reservation {
                // FIXME
                // label.text = reservation.label
                label.text = "ACTIVE RESERVATION"
                self.setMapRegion(reservation)
                self.setMapPin(reservation)
            }
        }
    }

    fileprivate func setMapRegion(_ reservation: Reservation) {
        let center = reservation.parking.coordinate()
        let region = MKCoordinateRegionMakeWithDistance(center, parkingRange, parkingRange)
        self.mapView.setRegion(region, animated: true)
        self.mapView.regionThatFits(region)
    }

    fileprivate func setMapPin(_ reservation: Reservation) {
        let centerAnnotation = MKPointAnnotation.init()
        centerAnnotation.coordinate = reservation.parking.coordinate()
        self.mapView.addAnnotation(centerAnnotation)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? ApyaLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
}
