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

class BookParkingViewController: UIViewController {

    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var availabilityLabel: UILabel!
    @IBOutlet var creditCardLabel: UnderlineTextField!
    @IBOutlet var vehiculeLabel: UnderlineTextField!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var confirmButton: CircularButton!

    var endTimeParking: String!
    var totalCost: Float!
    var sliderValue: Int!
    var paymentContext: STPPaymentContext!
    var parking: Parking!

    var tapCloseButtonActionHandler : ((Void) -> Void)?

    @IBAction func sliderChanged(_ sender: Any) {
        setSliderValue()
        setTimeLabel()
        setCostLabel()
    }
    
    @IBAction func tappedCloseArrow(_ sender: Any) {
        self.tapCloseButtonActionHandler?()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tappedConfirm(_ sender: Any) {
        if !parking.isAvailable {
            super.displayErrorMessage(NSLocalizedString("find.error.busy", comment: "Busy parking can't be rented"))
        } else if parking.customerId == AppState.shared.customer.id {
            super.displayErrorMessage(NSLocalizedString("find.error.own", comment: "Own parking can't be rented"))
        } else {
            // TODO: Internationalize
            let paymentMessage = "Confirm payment of \(String.init(format: "%.02f", totalCost))$ to get a parking until \(endTimeParking!)"
            let alertController = UIAlertController.init(title: "Confirm payment", message: paymentMessage, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                print("Canceled")
            }

            let okAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
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

        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView.init(effect: effect)
        blurView.frame = CGRect.init(x: 0.0, y: 0.0, width: view.bounds.width, height: 20.0)
        parkingImageView.addSubview(blurView)

        // TODO CHANGE THIS
        paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addressLabel.text = parking.address
        availabilityLabel.text = "\(NSLocalizedString("find.label.availability", comment: "header")) \(parking.availabilityInfo.stopTime)"

        let minuteDelta = self.parking.stopDate().timeIntervalSince(Date.init()) / 60
        self.timeSlider.maximumValue = Float(minuteDelta)

        setSliderValue()
        setTimeLabel()
        setCostLabel()
        setVehiculeLabel()

        if let url = parking.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            parkingImageView.sd_setImage(with: imageReference)
        }
    }

    func completeBooking() {
        self.paymentContext.paymentAmount = Int(self.totalCost * 100)
        self.paymentContext.requestPayment()
    }

    func setSliderValue() {
        var value = Int(timeSlider.value)
        let stepSize = 15
        value = (value - value % stepSize)
        self.sliderValue = value
    }

    func setTimeLabel() {
        let calendar = Calendar.current
        let until = calendar.date(byAdding: Calendar.Component.minute, value: self.sliderValue, to: Date())
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "HH:mm"
        endTimeParking = dateFormatter.string(from: until!)
        timeLabel.text = "\(NSLocalizedString("find.label.until", comment: "label displaying time left")) \(endTimeParking!)"
    }

    func setCostLabel() {
        totalCost = (Float(self.sliderValue!) / 60 * parking.price) + 0.5
        costLabel.text = "\(NSLocalizedString("find.label.cost", comment: "label displaying cost")) \(String.init(format: "%.02f", totalCost)) $"
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

        let calendar = Calendar.current
        let now = calendar.dateComponents(in: NSTimeZone.local, from: Date.init())
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "HH:mm"
        let startTime = dateFormatter.string(from: now.date!)

        let charge = Charge.init(customer: AppState.shared.customer.stripeId, amount: paymentContext.paymentAmount, currency: paymentContext.paymentCurrency, parkingId: parking.id!)

        let reservation = NewReservation.init(parkingId: parking.id!, customerId: AppState.shared.customer.id, isActive: true, startTime: startTime, stopTime: endTimeParking, totalCost: self.totalCost, charge: charge)

        reservation.persist() { (successfulReservation, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if let successfulReservation = successfulReservation {
                AppState.shared.customer.reservations.append(successfulReservation)
                self.tapCloseButtonActionHandler?()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        creditCardLabel.text = paymentContext.selectedPaymentMethod?.label
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
