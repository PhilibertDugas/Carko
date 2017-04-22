//
//  ParkingAnnotationView.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-15.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import MapKit

class ParkingAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        let parkingAnnotation = annotation as! ParkingAnnotation
        let parking = parkingAnnotation.parking

        if parking.isAvailable {
            self.image = UIImage.init(named: "pin-apya-green")
        } else {
            self.image = UIImage.init(named: "pin-apya-gray")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
