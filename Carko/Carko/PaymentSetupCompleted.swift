//
//  PaymentSetupCompleted.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-05-12.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class PaymentSetupCompleted: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var changeButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("PayoutSetupCompleted", owner: self, options: nil)
        guard let content = view else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }

}
