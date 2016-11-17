//
//  ParkingAnnotation.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import MapKit

class ParkingAnnotation: NSObject, MKAnnotation {
    var parking: Parking
    var coordinate: CLLocationCoordinate2D

    init(parking: Parking) {
        self.parking = parking
        self.coordinate = CLLocationCoordinate2D.init(latitude: parking.latitude, longitude: parking.longitude)

        super.init()
    }
}
