//
//  NSLayoutConstraintExtension.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-26.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
