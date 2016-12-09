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

class ProfileViewController: UITableViewController {

    @IBOutlet var creditCardLabel: UILabel!
    @IBOutlet var vehiculeLabel: UILabel!
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var creditCardImage: UIImageView!

    var paymentContext: STPPaymentContext!

    func logoutTapped() {
        try! FIRAuth.auth()!.signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"

        displayNameLabel.text = "\(AppState.sharedInstance.currentUser.firstName!) \(AppState.sharedInstance.currentUser.lastName!)"

        emailLabel.text = "\(AppState.sharedInstance.currentUser.email)"

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.sharedClient)
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        setCreditCardLabel(paymentContext: paymentContext)
    }

    func setCreditCardLabel(paymentContext: STPPaymentContext) {
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            creditCardLabel.text = paymentMethod.label
            creditCardImage.image = paymentMethod.image
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            handlePaymentSection(cellIndex: indexPath.row)
        case 2:
            logoutTapped()
            break
        default:
            break
        }
    }

    func handlePaymentSection(cellIndex: Int) {
        switch cellIndex {
        case 0:
            self.paymentContext.pushPaymentMethodsViewController()
            break
        default:
            break
        }
    }
}

extension ProfileViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        return
    }

    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        setCreditCardLabel(paymentContext: paymentContext)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        return
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        return
    }
}
