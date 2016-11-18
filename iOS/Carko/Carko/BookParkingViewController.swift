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

    @IBOutlet var addressLabel: UITextField!
    @IBOutlet var creditCardLabel: UILabel!

    var paymentContext: STPPaymentContext!
    var parking: Parking!

     var tapCloseButtonActionHandler : ((Void) -> Void)?

    @IBAction func tappedCloseArrow(_ sender: Any) {
        self.tapCloseButtonActionHandler?()
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.text = parking.address

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(BookParkingViewController.tappedCreditCard))
        creditCardLabel.addGestureRecognizer(tapGesture)

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.sharedClient)
        paymentContext.paymentAmount = Int(parking.price * 100)
        // TODO CHANGE THIS
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BookParkingViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("BookParkingViewController viewWillDisappear")
    }

    func tappedCreditCard() {
        paymentContext.presentPaymentMethodsViewController()
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
