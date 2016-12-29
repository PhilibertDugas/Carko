//
//  MarkerPopup.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-19.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class MarkerPopup: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("MarkerPopup", owner: self, options: nil)
        guard let content = view else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        content.backgroundColor = UIColor.clear
        self.addSubview(content)
    }
}
