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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerView.nameLabel.text = "\(AppState.shared.customer.firstName) \(AppState.shared.customer.lastName)"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let revealViewController = self.revealViewController()
        revealViewController?.revealToggle(sender)
    }
}
