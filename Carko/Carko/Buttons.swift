//
//  RoundedCornerButton.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-22.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class RoundedCornerButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 1
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(netHex: 0x515052).cgColor
    }
}

class CircularButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
}

class NoBorderButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 0
    }
}
