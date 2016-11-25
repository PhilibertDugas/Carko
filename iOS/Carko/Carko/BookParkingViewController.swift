//
//  BookParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-20.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe

class BookParkingViewController: UIViewController {

    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var availabilityLabel: UILabel!
    @IBOutlet var creditCardLabel: UnderlineTextField!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!

    @IBOutlet var timeSlider: UISlider!

    var endTimeParking: String!
    var totalCost: Float!
    var sliderValue: Int?
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
        let paymentMessage = "Confirm payment of \(String.init(format: "%.02f", totalCost))$ to get a parking until \(endTimeParking!)"
        let alertController = UIAlertController.init(title: "Confirm payment", message: paymentMessage, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            print("Canceled")
        }

        let okAction = UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.paymentContext.paymentAmount = Int(self.totalCost * 100)
            self.paymentContext.requestPayment()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.text = parking.address
        availabilityLabel.text = "Available until \(parking.availabilityInfo.stopTime)"
        creditCardLabel.delegate = self

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.sharedClient)
        paymentContext.paymentAmount = Int(parking.price * 100)
        // TODO CHANGE THIS
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    func setSliderValue() {
        var value = Int(timeSlider.value)
        let stepSize = 15
        value = (value - value % stepSize)
        self.sliderValue = value
    }

    func setTimeLabel() {
        let calendar = Calendar.current
        let until = calendar.date(byAdding: Calendar.Component.minute, value: self.sliderValue!, to: Date())
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "HH:mm"
        endTimeParking = dateFormatter.string(from: until!)
        timeLabel.text = "Parked until: " + endTimeParking
    }

    func setCostLabel() {
        totalCost = Float(self.sliderValue!) / 60 * parking.price
        costLabel.text = "Cost: " + String.init(format: "%.02f", totalCost) + "$"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let minuteDelta = self.parking.stopDate().timeIntervalSince(Date.init()) / 60
        self.timeSlider.maximumValue = Float(minuteDelta)

        setSliderValue()
        setTimeLabel()
        setCostLabel()
    }
}

extension BookParkingViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 10 {
            paymentContext.presentPaymentMethodsViewController()
            return false
        } else {
            return true
        }
    }
}

extension BookParkingViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        CarkoAPIClient.sharedClient.postCharge(paymentResult.source, paymentContext: paymentContext, completion: completion)
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
