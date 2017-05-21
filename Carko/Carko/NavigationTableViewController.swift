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
        self.paymentContext.presentPaymentMethodsViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.paymentContext = STPPaymentContext.init(apiAdapter: APIClient.shared)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let revealViewController = self.revealViewController()
        revealViewController?.revealToggle(sender)
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

extension NavigationTableViewController: STPPaymentContextDelegate {
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

