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
    @IBOutlet var payoutLabel: UILabel!

    var paymentContext: STPPaymentContext!

    func logoutTapped() {
        try! FIRAuth.auth()!.signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameLabel.text = "\(AppState.shared.customer.firstName) \(AppState.shared.customer.lastName)"

        emailLabel.text = "\(AppState.shared.customer.email)"

        paymentContext = STPPaymentContext.init(apiAdapter: CarkoAPIClient.shared)
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        setCreditCardLabel(paymentContext: paymentContext)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let bankName = AppState.shared.customer.externalBankName {
            payoutLabel.text = bankName
        }

        if let vehicule = AppState.shared.customer.vehicule {
            vehiculeLabel.text = vehicule.description
        }
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
        case 1:
            self.performSegue(withIdentifier: "showVehiculeInformation", sender: nil)
            break
        case 2:
            self.performSegue(withIdentifier: "showAccountCreation", sender: nil)
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
