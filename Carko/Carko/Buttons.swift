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

class SmallRoundedCornerButton: UIButton {
    var gradient: CAGradientLayer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        applyGradient()
        layer.cornerRadius = 10
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyGradient()
        layer.cornerRadius = 10
    }

    fileprivate func applyGradient() {
        gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.accentGradientColor.cgColor, UIColor.accentColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.cornerRadius = 10
        self.layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = self.bounds
    }
}

class SecondarySmallRoundedCornerButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 10

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
    }
}

class CircularButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 0.5 * bounds.size.width
        clipsToBounds = true
    }
}

class NoBorderButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 0
    }
}
