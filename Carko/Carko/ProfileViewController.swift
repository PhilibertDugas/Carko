//
//  ProfileViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import Stripe

class ProfileViewController: UITableViewController {

    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayNameLabel.text = AuthenticationHelper.getCustomer().displayName
        emailLabel.text = AuthenticationHelper.getCustomer().email
    }
}

extension ProfileViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            logoutTapped()
            break
        default:
            break
        }
    }

    func logoutTapped() {
        AuthenticationHelper.resetCustomer()
        NotificationCenter.default.post(name: Notification.Name.init("LoggedOut"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
