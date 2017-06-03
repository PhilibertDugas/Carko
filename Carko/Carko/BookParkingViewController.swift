//
//  BookParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-20.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe
import FirebaseStorageUI

protocol ReservationDelegate {
    func reservationCompleted()
}

class BookParkingViewController: UIViewController {
    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var confirmButton: RoundedCornerButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var parkingLabel: UILabel!

    var paymentContext: STPPaymentContext!
    var parking: Parking!
    var event: Event!
    var delegate: ReservationDelegate!

    let fullView: CGFloat = 10
    var partialView: CGFloat {
        //return UIScreen.main.bounds.height - (left.frame.maxY + UIApplication.shared.statusBarFrame.height)
        return UIScreen.main.bounds.height - (180 + UIApplication.shared.statusBarFrame.height)
    }

    @IBAction func tappedCloseArrow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tappedConfirm(_ sender: Any) {
        if !parking.isAvailable {
            super.displayErrorMessage(NSLocalizedString("The parking is currently busy", comment: ""))
        } else if parking.customerId == AppState.shared.customer.id {
            super.displayErrorMessage(NSLocalizedString("The parking is your own. You can't rent your own parking", comment: ""))
        } else if AppState.shared.customer.vehicule == nil {
            super.displayErrorMessage("Please set your vehicule information in the profile section")
        } else if paymentContext.selectedPaymentMethod == nil {
            super.displayErrorMessage("Please select a payment method")
        } else {
            let translatedMessage = NSLocalizedString("Confirm payment of %@ to get a parking on %@", comment: "")
            let paymentMessage = String.init(format: translatedMessage, event.price.asLocaleCurrency, event.endTime.formattedDays)
            let alertController = UIAlertController.init(title: NSLocalizedString("Confirm Payment", comment: ""), message: paymentMessage, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            }

            let okAction = UIAlertAction.init(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                self.completeBooking()
            }

            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO CHANGE THIS
        paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BookParkingViewController.panGesture))
        view.addGestureRecognizer(gesture)

        self.roundViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()

        self.indicator.isHidden = true
        addressLabel.text = parking.address
        timeLabel.text = self.event.endTime.formattedDays
        costLabel.text = self.event.price.asLocaleCurrency
        parkingLabel.text = self.parking.pDescription


        if let url = parking.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            parkingImageView.sd_setImage(with: imageReference)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.partialView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.size.width, height: frame!.size.height)
        })
    }

    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }

    func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        if ( y + translation.y >= fullView) && (y + translation.y <= partialView ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }

        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y > 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else if velocity.y < 0 {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    if self.view.frame.origin.y < (self.view.frame.height / 2) {
                        self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)

                    } else {
                        self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                    }
                }

            }, completion: nil)
        }
    }

    func roundViews() {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }

    func completeBooking() {
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        self.paymentContext.paymentAmount = Int(self.event.price * 100)
        self.paymentContext.requestPayment()
    }
}

extension BookParkingViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 10 {
            paymentContext.presentPaymentMethodsViewController()
            return false
        } else if textField.tag == 11 {
            return false
        } else {
            return true
        }
    }
}

extension BookParkingViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        let charge = Charge.init(
            customer: AppState.shared.customer.stripeId,
            amount: paymentContext.paymentAmount,
            currency: paymentContext.paymentCurrency,
            parkingId: parking.id!
        )

        let reservation = NewReservation.init(
            label: self.event.label,
            parkingId: parking.id!,
            customerId: AppState.shared.customer.id,
            isActive: true,
            startTime: self.event.startTime,
            stopTime: self.event.stopTime,
            totalCost: self.event.price,
            charge: charge
        )

        reservation.persist() { (successfulReservation, error) in
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if successfulReservation != nil {
                self.delegate.reservationCompleted()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.paymentContext = paymentContext
        return
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        return
    }

    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        return
    }
}
