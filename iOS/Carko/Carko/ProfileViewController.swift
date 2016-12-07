//
//  ProfileViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet var displayNameLabel: UILabel!

    var paymentContext: STPPaymentContext!
    
    @IBAction func showTapped(_ sender: AnyObject) {
        self.paymentContext.pushPaymentMethodsViewController()
    }
    
    @IBAction func logoutTapped(_ sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        displayNameLabel.text = "\((AppState.sharedInstance.currentUser?.firstName)!) \((AppState.sharedInstance.currentUser?.lastName)!)"

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.sharedClient)
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
}

extension ProfileViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        return
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        return
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        return
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        return
    }
}
