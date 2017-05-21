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

    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayNameLabel.text = "\(AppState.shared.customer.firstName) \(AppState.shared.customer.lastName)"
        emailLabel.text = "\(AppState.shared.customer.email)"
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
        try! FIRAuth.auth()!.signOut()
        UserDefaults.standard.removeObject(forKey: "user")
        self.dismiss(animated: true, completion: nil)
    }
}
