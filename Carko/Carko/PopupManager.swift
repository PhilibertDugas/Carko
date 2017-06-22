//
//  PopupManager.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-21.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import UIKit

class PopupManager {
    var successPopup: SuccessPopup
    var parentView: UIView
    var blur: UIVisualEffectView!

    init(parentView: UIView, title: String, description: String) {
        self.parentView = parentView
        successPopup = SuccessPopup.init(frame: CGRect.init(x: 0, y: 0, width: 0.66 * parentView.frame.width, height: 0.5 * parentView.frame.height))
        successPopup.view.backgroundColor = UIColor.secondaryViewsBlack
        successPopup.titleLabel.text = title
        successPopup.descriptionLabel.text = description
        // 40.0 for navigation controller bar
        successPopup.center = CGPoint.init(x: parentView.center.x, y: parentView.center.y - 40.0)
        successPopup.isHidden = false
        successPopup.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        successPopup.view.alpha = 0.0
    }

    func displayPopup() {
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        blur = UIVisualEffectView.init(effect: blurEffect)
        blur.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        blur.frame = UIScreen.main.bounds
        parentView.superview?.insertSubview(blur, aboveSubview: parentView)

        blur.addSubview(successPopup)
        UIView.animate(withDuration: 0.25, animations: {
            self.successPopup.view.alpha = 1.0
            self.successPopup.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    func removePopup() {
        blur.removeFromSuperview()
        UIView.animate(withDuration: 0.25, animations: {
            self.successPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.successPopup.alpha = 0.0
        }) { (finished) in
            if finished {
                self.successPopup.isHidden = true
            }
        }
    }
}
