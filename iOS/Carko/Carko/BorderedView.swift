//
//  BorderedView.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-06.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class BorderedView: UIView {

    override func draw(_ rect: CGRect) {
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = CGFloat.init(1.0)
    }
}
