//
//  EventCollectionViewCell.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-20.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    @IBOutlet var image: UIImageView!
    @IBOutlet var imageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var label: UILabel!
    @IBOutlet var time: UILabel!

    var event: Event? {
        didSet {
            if let event = event {
                if let url = event.photoURL {
                    let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
                    image.sd_setImage(with: imageReference, placeholderImage: UIImage.init(named: "placeholder-1"))
                }
                label.text = event.label
                time.text = event.startTime
            }
        }
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? ApyaLayoutAttributes {
            imageViewHeightLayoutConstraint.constant = attributes.photoHeight
        }
    }
}
