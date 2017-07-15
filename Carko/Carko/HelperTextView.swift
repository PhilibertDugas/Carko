//
//  HelperTextView.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-07-13.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class HelperTextView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("HelperText", owner: self, options: nil)
        guard let content = view else { return }
        content.layer.cornerRadius = 10
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }

}
