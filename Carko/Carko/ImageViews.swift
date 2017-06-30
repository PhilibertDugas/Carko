//
//  ImageViews.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-05-24.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class RoundedCornerImageView: UIImageView {
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

class CircleImageView: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 0.5 * frame.size.width
        clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 0.5 * frame.size.width
        clipsToBounds = true
    }

}
