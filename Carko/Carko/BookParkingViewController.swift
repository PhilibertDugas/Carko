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

    @IBOutlet var creditCardImage: UIImageView!
    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var creditCardLabel: UnderlineTextField!
    @IBOutlet var vehiculeLabel: UnderlineTextField!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var confirmButton: RoundedCornerButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var parkingLabel: UILabel!

    var paymentContext: STPPaymentContext!
    var parking: Parking!
    var event: Event!
    var delegate: ReservationDelegate!

    var tapCloseButtonActionHandler : ((Void) -> Void)?
    
    @IBAction func tappedCloseArrow(_ sender: Any) {
        self.tapCloseButtonActionHandler?()
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
        creditCardLabel.delegate = self
        vehiculeLabel.delegate = self

        // TODO CHANGE THIS
        paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.indicator.isHidden = true

        addressLabel.text = parking.address
        timeLabel.text = self.event.endTime.formattedDays
        costLabel.text = self.event.price.asLocaleCurrency
        parkingLabel.text = self.parking.pDescription


        setVehiculeLabel()

        if let url = parking.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            parkingImageView.sd_setImage(with: imageReference)
        }
    }

    func completeBooking() {
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        self.paymentContext.paymentAmount = Int(self.event.price * 100)
        self.paymentContext.requestPayment()
    }

    func setVehiculeLabel() {
        if let vehicule = AppState.shared.customer.vehicule {
            vehiculeLabel.text = vehicule.description
        }
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
                self.tapCloseButtonActionHandler?()
                self.delegate.reservationCompleted()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        creditCardLabel.text = paymentContext.selectedPaymentMethod?.label
        creditCardImage.image = paymentContext.selectedPaymentMethod?.image
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
