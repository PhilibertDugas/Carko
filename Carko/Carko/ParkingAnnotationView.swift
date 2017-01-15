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
        self.image = UIImage.init(named: "placeholder-green")

        let label = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: self.frame.width, height: self.frame.height))
        label.text = "\(parking.price)$/h"
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        label.textColor = UIColor.init(netHex: 0x515052)

        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
