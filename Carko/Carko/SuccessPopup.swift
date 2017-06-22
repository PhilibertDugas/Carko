//
//  SuccessPopup.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-21.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class SuccessPopup: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var confirmButton: SmallRoundedCornerButton!
    @IBOutlet var warningMessage: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("SuccessPopup", owner: self, options: nil)
        guard let content = view else { return }
        content.layer.cornerRadius = 10
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        content.backgroundColor = UIColor.clear
        self.addSubview(content)
    }
}
