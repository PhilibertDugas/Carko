//
//  Segues.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-07-01.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

@objc(FadeSegue)
class FadeSegue: UIStoryboardSegue {
    override func perform() {
        let transition = CATransition.init()
        transition.duration = 0.3;
        transition.type = kCATransitionFade;
        self.source.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.source.navigationController?.pushViewController(self.destination, animated: false)
    }
}
