//
//  ParkingAnnotationView.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-15.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import MapKit

class NewParkingPin: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = UIImage.init(named: "pin-available")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
