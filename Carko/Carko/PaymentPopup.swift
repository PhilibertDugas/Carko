//
//  PaymentPopup.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-05.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class PaymentPopup: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var creditCardLabel: UILabel!
    @IBOutlet var confirmButton: SmallRoundedCornerButton!
    @IBOutlet var cancelButton: SecondarySmallRoundedCornerButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("PaymentPopup", owner: self, options: nil)
        guard let content = view else { return }
        content.layer.cornerRadius = 10
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        content.backgroundColor = UIColor.clear
        self.addSubview(content)
    }

}
