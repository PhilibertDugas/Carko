//
//  ProfileHeaderView.swift
//  Carko
//
//  Created by Guillaume Lalande on 2017-05-04.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import QuartzCore

class ProfileHeaderView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var nameLabel: UILabel!


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)
        guard let content = view else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        //headerView.layer.cornerRadius = 7
        //headerView.layer.masksToBounds = true
        //headerView.layer.borderColor = (#colorLiteral(red: 0.8200154901, green: 0.1567437351, blue: 0.2629780173, alpha: 1)).cgColor
        //headerView.layer.borderWidth = 2.0
        self.addSubview(content)
    }
}
