//
//  NavigationViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2017-05-04.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

class NavigationViewController: UIViewController {

    @IBOutlet weak var headerView: ProfileHeaderView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AuthenticationHelper.customerAvailable() {
            let customer = AuthenticationHelper.getCustomer()
            self.headerView.nameLabel.text = "\(customer.firstName) \(customer.lastName)"
        } else {
            self.headerView.nameLabel.text = ""
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let revealViewController = self.revealViewController()
        revealViewController?.revealToggle(sender)
    }
}
