//
//  AuthPickerViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-18.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class AuthPickerViewController: FUIAuthPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.secondaryViewsBlack
        self.hideTableViewRows()
        self.setupCityGif()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func hideTableViewRows() {
        if let tableView = self.view as? UITableView {
            tableView.isScrollEnabled = false
            tableView.separatorColor = UIColor.secondaryViewsBlack
            tableView.tableFooterView = UIView.init()
        }
    }

    private func setupCityGif() {
        let filePath = Bundle.main.path(forResource: "city", ofType: "gif")
        let gif = NSData.init(contentsOfFile: filePath!)
        let webView = UIWebView.init(frame: self.view.frame)
        webView.load(gif! as Data, mimeType: "image/gif", textEncodingName: String.init(), baseURL: NSURL.init() as URL)
        webView.isUserInteractionEnabled = false
        self.view.insertSubview(webView, at: 0)
    }
}
