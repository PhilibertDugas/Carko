//
//  ParkingAnnotation.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps

class ParkingAnnotation: NSObject, MKAnnotation {
    var parking: Parking
    var event: Event?
    var coordinate: CLLocationCoordinate2D

    init(parking: Parking, event: Event?) {
        self.parking = parking
        self.event = event
        self.coordinate = CLLocationCoordinate2D.init(latitude: parking.latitude, longitude: parking.longitude)
        super.init()
    }
}

class ParkingMarker: GMSMarker {
    var parking: Parking
    var event: Event?

    init(parking: Parking, event: Event?) {
        self.parking = parking
        self.event = event

        super.init()

        if parking.isAvailable {
            self.iconView = UIImageView.init(image: UIImage.init(named: "pin-available"))

        } else {
            self.iconView = UIImageView.init(image: UIImage.init(named: "pin-unavailable"))
        }
    }
}
