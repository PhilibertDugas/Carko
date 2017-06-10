//
//  NavigationTableViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2017-05-04.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import Stripe
import FirebaseAuth

class NavigationTableViewController: UITableViewController {
    var paymentContext: STPPaymentContext!

    @IBAction func paymentTapped(_ sender: Any) {
        let revealViewController = self.revealViewController()
        revealViewController?.revealToggle(sender)
        if AuthenticationHelper.customerAvailable() {
            self.paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
            self.paymentContext.hostViewController = self
            self.paymentContext.presentPaymentMethodsViewController()
        } else {
            self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "showLoginScreen" {
            let revealViewController = self.revealViewController()
            revealViewController?.revealToggle(sender)
            if !AuthenticationHelper.customerAvailable() {
                self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
            }
        }
    }

}

extension NavigationTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        switch cell.tag {
        case 4:
            self.contactUsMail()
            break;
        default:
            break;
        }
    }

    fileprivate func contactUsMail() {
        UIApplication.shared.open(URL.init(string: "mailto:\(AppState.companyEmail)")!)
    }
}
