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
        let lowerLeft = CGPoint.init(x: rect.minX, y: rect.maxY)
        let lowerRight = CGPoint.init(x: rect.maxX, y: rect.maxY)
        let topLeft = CGPoint.init(x: rect.minX, y: rect.minY)
        let topRight = CGPoint.init(x: rect.maxX, y: rect.minY)

        let path = UIBezierPath.init()
        path.move(to: lowerLeft)
        path.addLine(to: lowerRight)

        path.move(to: lowerLeft)
        path.addLine(to: topLeft)

        path.move(to: topLeft)
        path.addLine(to: topRight)

        path.move(to: lowerRight)
        path.addLine(to: topRight)

        path.lineWidth = 1.0
        tintColor.setStroke()
        path.stroke()
        super.draw(rect)
    }
}

class CircularView: UIView {
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
        super.draw(rect)
    }
}
