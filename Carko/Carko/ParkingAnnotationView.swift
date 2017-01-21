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
            let label = UILabel.init(frame: CGRect.init(x: 2, y: -8, width: self.frame.width - 4, height: self.frame.height))
            label.text = "\(parking.price)$"
            label.adjustsFontSizeToFitWidth = true
            label.textColor = UIColor.init(netHex: 0x515052)

            self.addSubview(label)
        } else {
            self.image = UIImage.init(named: "pin-apya-gray")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
