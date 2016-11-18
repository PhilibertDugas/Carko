//
//  FindParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import ARNTransitionAnimator
import MapKit

class FindParkingViewController: UIViewController {

    @IBOutlet var popupView: MarkerPopup!
    @IBOutlet var containerView: UIView!
    var tabBar: UITabBar!

    var bookParkingVC: BookParkingViewController!
    var animator: ARNTransitionAnimator!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("FindParkingViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("FindParkingViewController viewWillDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar = self.tabBarController?.tabBar

        popupView.isHidden = true
        self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
        self.bookParkingVC.modalPresentationStyle = .overFullScreen
        self.bookParkingVC.tapCloseButtonActionHandler = { _ in
            self.tabBar.frame.origin.y = self.containerView.frame.height
        }

        NotificationCenter.default.addObserver(self, selector: #selector(FindParkingViewController.parkingSelected), name: Notification.Name.init(rawValue: "ParkingSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FindParkingViewController.parkingDeselected), name: Notification.Name.init(rawValue: "ParkingDeselected"), object: nil)

        self.setupAnimator()
    }

    func parkingSelected(_ notification: Notification) {
        if let parkingData = notification.userInfo as? [String: Any] {
            let parking = parkingData["data"] as! Parking
            self.bookParkingVC.parking = parking
            popupView.descriptionLabel.text = parking.address
            popupView.isHidden = false
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(FindParkingViewController.annotationTapped))
            popupView.addGestureRecognizer(tapGesture)
        }
    }

    func parkingDeselected() {
        popupView.isHidden = true
    }

    func annotationTapped() {
        self.present(self.bookParkingVC, animated: true, completion: nil)
    }

    func setupAnimator() {
        let animation = ParkingTransitionAnimation(rootVC: self, modalVC: self.bookParkingVC)

        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(_self.bookParkingVC.view)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }

        let gestureHandler = TransitionGestureHandler(targetVC: self, direction: .top)
        gestureHandler.registerGesture(self.popupView)
        gestureHandler.panCompletionThreshold = 15.0

        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)

        self.bookParkingVC.transitioningDelegate = self.animator
    }
}


