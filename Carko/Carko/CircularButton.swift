//
//  CircularButton.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-20.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class CircularButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
}
