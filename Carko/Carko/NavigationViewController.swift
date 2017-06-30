//
//  NavigationViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2017-05-04.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class NavigationViewController: UIViewController {

    @IBOutlet weak var headerView: ProfileHeaderView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AuthenticationHelper.customerAvailable() {
            let customer = AuthenticationHelper.getCustomer()
            self.headerView.nameLabel.text = customer.displayName
            if let current = FBSDKAccessToken.current() {
                if let id = current.userID {
                    ImageLoaderHelper.loadPublicImageIntoView(self.headerView.profileImage, url: URL.init(string: "https://graph.facebook.com/\(id)/picture?type=large"))
                }
            }
        } else {
            self.headerView.profileImage.image = nil
            self.headerView.nameLabel.text = Translations.t("Sign in")
        }
    }

    @IBAction func profileTapped(_ sender: Any) {
        let revealViewController = self.revealViewController()
        revealViewController?.revealToggle(sender)
        if AuthenticationHelper.customerAvailable() {
            self.performSegue(withIdentifier: "presentProfile", sender: nil)
        } else {
            self.present(AuthenticationHelper.shared.getAuthController(), animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.profileImage.layer.cornerRadius = self.headerView.profileImage.frame.size.width / 2
    }
}
