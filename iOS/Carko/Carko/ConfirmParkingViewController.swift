//
//  ConfirmParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-20.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe

class ConfirmParkingViewController: UIViewController {

    @IBOutlet var addressTextField: UnderlineTextField!
    @IBOutlet var priceTextField: UnderlineTextField!
    @IBOutlet var creditCardView: UIView!
    @IBOutlet var creditCardTextField: UITextField!

    var parking: Parking!
    var paymentContext: STPPaymentContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        addressTextField.text = parking.address
        priceTextField.text = "\(parking.price)"
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(ConfirmParkingViewController.tappedCreditCard))
        creditCardView.addGestureRecognizer(tapGesture)

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.sharedClient)
        paymentContext.paymentAmount = Int(parking.price * 100)
        // TODO CHANGE THIS
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    @IBAction func tappedConfirmed(_ sender: AnyObject) {
        paymentContext.requestPayment()
    }
    
    func tappedCreditCard() {
        paymentContext.presentPaymentMethodsViewController()
    }
}

extension ConfirmParkingViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        CarkoAPIClient.sharedClient.postCharge(paymentResult.source, paymentContext: paymentContext, completion: completion)
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        creditCardTextField.text = paymentContext.selectedPaymentMethod?.label
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
