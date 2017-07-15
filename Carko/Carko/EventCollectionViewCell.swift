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
    @IBOutlet var label: UILabel!
    @IBOutlet var priceLabel: UILabel!

    var event: Event? {
        didSet {
            if let event = event {
                if let url = event.photoURL {
                    isUserInteractionEnabled = true
                    priceLabel.isHidden = false
                    label.isHidden = false
                    ImageLoaderHelper.loadImageFromUrl(image, url: url)
                } else {
                    // Placeholder cells which don't have a photoURL shouldn't be touched / interacted with
                    isUserInteractionEnabled = false
                    priceLabel.isHidden = true
                    label.isHidden = true
                }
                label.text = "\(DateHelper.getDay(event.startTime)) \(DateHelper.getMonth(event.startTime))"
                priceLabel.text = Translations.t("Parking: ") + event.price.asLocaleCurrency
            }
        }
    }
}
