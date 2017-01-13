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
            super.displayErrorMessage(NSLocalizedString("The parking is currently busy", comment: ""))
        } else if parking.customerId == AppState.shared.customer.id {
            super.displayErrorMessage(NSLocalizedString("The parking is your own. You can't rent your own parking", comment: ""))
        } else {
            let paymentMessage = String.init(format: NSLocalizedString("Confirm payment of %s$ to get a parking until %s", comment: ""), [String.init(format: "%.02f", totalCost), endTimeParking!])
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

        // TODO CHANGE THIS
        paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addressLabel.text = parking.address
        availabilityLabel.text = "\(NSLocalizedString("Available until", comment: "")) \(parking.availabilityInfo.stopTime)"

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
        endTimeParking = AvailabilityInfo.formatter().string(from: until!)
        timeLabel.text = "\(NSLocalizedString("Until", comment: "")) \(endTimeParking!)"
    }

    func setCostLabel() {
        totalCost = (Float(self.sliderValue!) / 60 * parking.price) + 0.5
        costLabel.text = "\(NSLocalizedString("Cost:", comment: "")) \(String.init(format: "%.02f", totalCost)) $"
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
        let startTime = AvailabilityInfo.formatter().string(from: now.date!)

        let charge = Charge.init(customer: AppState.shared.customer.stripeId, amount: paymentContext.paymentAmount, currency: paymentContext.paymentCurrency, parkingId: parking.id!)

        let reservation = NewReservation.init(parkingId: parking.id!, customerId: AppState.shared.customer.id, isActive: true, startTime: startTime, stopTime: endTimeParking, totalCost: self.totalCost, charge: charge)

        reservation.persist() { (successfulReservation, error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else if successfulReservation != nil {
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
