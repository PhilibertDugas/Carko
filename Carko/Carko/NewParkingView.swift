//
//  NewParkingView.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-14.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class NewParkingView: UIView {

    @IBOutlet weak var view: UIView!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var mainActionButton: SmallRoundedCornerButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("NewParkingView", owner: self, options: nil)
        guard let content = view else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        content.backgroundColor = UIColor.clear
        self.addSubview(content)
    }

}
