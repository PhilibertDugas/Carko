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
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }

}
