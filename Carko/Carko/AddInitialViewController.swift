//
//  AddInitialViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-02.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit

class AddInitialViewController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.customer.parkings.count > 0 {
            self.performSegue(withIdentifier: "firstParking", sender: nil)
        }
    }
}
