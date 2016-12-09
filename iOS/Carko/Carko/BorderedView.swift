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
        let startingPoint = CGPoint.init(x: rect.minX, y: rect.maxY)
        let endingPoint = CGPoint.init(x: rect.maxX, y: rect.maxY)

        let path = UIBezierPath.init()
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 2.0

        tintColor.setStroke()
        path.stroke()
    }
}
