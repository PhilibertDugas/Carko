//
//  PageContentViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var pageTitle: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.backgroundImage.image = UIImage(named: imageFile)
        self.pageTitle.text = titleText
    }
}
