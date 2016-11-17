//
//  ParkingTransitionAnimation.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import UIKit
import ARNTransitionAnimator

class ParkingTransitionAnimation : TransitionAnimatable {

    var rootVC: FindParkingViewController!
    var modalVC: BookParkingViewController!

    var completion: ((Bool) -> Void)?

    private var popupStartFrame: CGRect
    private var tabBarStartFrame: CGRect

    private var containerView: UIView?

    deinit {
        print("deinit ParkingTransitionAnimation")
    }

    init(rootVC: FindParkingViewController, modalVC: BookParkingViewController) {
        self.rootVC = rootVC
        self.modalVC = modalVC

        self.popupStartFrame = rootVC.popupView.frame
        self.tabBarStartFrame = rootVC.tabBar.frame
    }

    func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        self.containerView = containerView

        self.rootVC.view.insertSubview(self.modalVC.view, belowSubview: self.rootVC.tabBar)
        self.rootVC.view.setNeedsLayout()
        self.rootVC.view.layoutIfNeeded()
        self.modalVC.view.setNeedsLayout()
        self.modalVC.view.layoutIfNeeded()

        self.popupStartFrame = self.rootVC.popupView.frame
        self.tabBarStartFrame = self.rootVC.tabBar.frame
    }

    func willAnimation(_ transitionType: TransitionType, containerView: UIView) {
        if transitionType.isPresenting {
            self.rootVC.beginAppearanceTransition(true, animated: false)
            self.modalVC.view.frame.origin.y = self.rootVC.popupView.frame.origin.y + self.rootVC.popupView.frame.size.height
        } else {
            self.rootVC.beginAppearanceTransition(false, animated: false)
            self.rootVC.popupView.alpha = 1.0
            self.rootVC.popupView.frame.origin.y = -self.rootVC.popupView.bounds.size.height
            self.rootVC.tabBar.frame.origin.y = containerView.bounds.size.height
        }
    }

    func updateAnimation(_ transitionType: TransitionType, percentComplete: CGFloat) {
        if transitionType.isPresenting {
            // popupView
            let startOriginY = self.popupStartFrame.origin.y
            let endOriginY = -self.popupStartFrame.size.height
            let diff = -endOriginY + startOriginY

            // tabBar
            let tabStartOriginY = self.tabBarStartFrame.origin.y
            let tabEndOriginY = self.modalVC.view.frame.size.height
            let tabDiff = tabEndOriginY - tabStartOriginY

            let playerY = startOriginY - (diff * percentComplete)
            self.rootVC.popupView.frame.origin.y = max(min(playerY, self.popupStartFrame.origin.y), endOriginY)

            self.modalVC.view.frame.origin.y = self.rootVC.popupView.frame.origin.y + self.rootVC.popupView.frame.size.height
            let tabY = tabStartOriginY + (tabDiff * percentComplete)
            self.rootVC.tabBar.frame.origin.y = min(max(tabY, self.tabBarStartFrame.origin.y), tabEndOriginY)

            let alpha = 1.0 - (1.0 * percentComplete)
            self.rootVC.mapView.alpha = alpha + 0.5
            self.rootVC.tabBar.alpha = alpha
            self.rootVC.popupView.subviews.forEach { $0.alpha = alpha }
        } else {
            // popupView
            let startOriginY = 0 - self.rootVC.popupView.bounds.size.height
            let endOriginY = self.popupStartFrame.origin.y
            let diff = -startOriginY + endOriginY

            // tabBar
            let tabStartOriginY = self.rootVC.mapView.bounds.size.height
            let tabEndOriginY = self.tabBarStartFrame.origin.y
            let tabDiff = tabStartOriginY - tabEndOriginY

            self.rootVC.popupView.frame.origin.y = startOriginY + (diff * percentComplete)
            self.modalVC.view.frame.origin.y = self.rootVC.popupView.frame.origin.y + self.rootVC.popupView.frame.size.height

            self.rootVC.tabBar.frame.origin.y = tabStartOriginY - (tabDiff *  percentComplete)

            let alpha = 1.0 * percentComplete
            self.rootVC.mapView.alpha = alpha + 0.5
            self.rootVC.tabBar.alpha = alpha
            self.rootVC.popupView.alpha = 1.0
            self.rootVC.popupView.subviews.forEach { $0.alpha = alpha }
        }
    }

    func finishAnimation(_ transitionType: TransitionType, didComplete: Bool) {
        self.rootVC.endAppearanceTransition()

        if transitionType.isPresenting {
            if didComplete {
                self.rootVC.popupView.alpha = 0.0
                self.modalVC.view.removeFromSuperview()
                self.containerView?.addSubview(self.modalVC.view)
                self.completion?(transitionType.isPresenting)
            } else {
                self.rootVC.beginAppearanceTransition(true, animated: false)
                self.rootVC.endAppearanceTransition()
            }
        } else {
            if didComplete {
                self.modalVC.view.removeFromSuperview()
                self.completion?(transitionType.isPresenting)
            } else {
                self.rootVC.popupView.alpha = 0.0

                self.modalVC.view.removeFromSuperview()
                self.containerView?.addSubview(self.modalVC.view)

                self.rootVC.beginAppearanceTransition(false, animated: false)
                self.rootVC.endAppearanceTransition()
            }
        }
    }
}

extension ParkingTransitionAnimation {

    func sourceVC() -> UIViewController { return self.rootVC }

    func destVC() -> UIViewController { return self.modalVC }
}

