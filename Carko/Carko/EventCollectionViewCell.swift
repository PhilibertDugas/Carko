//
//  EventCollectionViewCell.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-20.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    var image: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        image = UIImageView.init(frame: frame)
        image.contentMode = UIViewContentMode.scaleAspectFit
        contentView.addSubview(image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
