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
        layer.cornerRadius = 3
        layer.borderWidth = 0.5
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 3
        layer.borderWidth = 0.5
    }
}

class CircularButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5 * bounds.size.width
        layer.borderWidth = 0.5
        clipsToBounds = true
    }
}

class NoBorderButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 0
    }
}
