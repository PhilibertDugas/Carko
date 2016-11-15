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

    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = parking.address

        // For longer swipe: http://stackoverflow.com/questions/4828833/uiswipegesturerecognizer-swipe-length
        let swipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(BookParkingViewController.swipedDown))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeGestureRecognizer)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(BookParkingViewController.tappedCreditCard))
        creditCardLabel.addGestureRecognizer(tapGesture)

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.sharedClient)
        paymentContext.paymentAmount = Int(parking.price * 100)
        // TODO CHANGE THIS
        paymentContext.paymentCurrency = "CAD"
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }

    func tappedCreditCard() {
        paymentContext.presentPaymentMethodsViewController()
    }

    func swipedDown() {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "didTapContinue" {
            let destinationViewController = segue.destination as! ConfirmParkingViewController
            destinationViewController.parking = parking
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
