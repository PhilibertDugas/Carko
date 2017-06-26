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
    var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.secondaryViewsBlack
        self.hideTableViewRows()
        self.setupCityGif()
        self.addCancel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.secondaryViewsBlack
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
        webView = UIWebView.init(frame: self.view.frame)
        webView.load(gif! as Data, mimeType: "image/gif", textEncodingName: String.init(), baseURL: NSURL.init() as URL)
        webView.isUserInteractionEnabled = false
        self.view.insertSubview(webView, at: 0)
    }

    private func addCancel() {
        let backgroundView = CircularView.init(frame: CGRect.init(x: 16, y: 36, width: 34, height: 34))
        backgroundView.backgroundColor = UIColor.secondaryViewsBlack

        let button = CircularButton.init(frame: CGRect.init(x: backgroundView.bounds.origin.x , y: backgroundView.bounds.origin.y, width: 17, height: 17))
        button.center = CGPoint.init(x: backgroundView.bounds.size.width / 2, y: backgroundView.bounds.size.height / 2)
        button.setBackgroundImage(UIImage.init(named: "cancel_icon"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)

        backgroundView.addSubview(button)
        self.view.insertSubview(backgroundView, aboveSubview: webView)
    }

    func buttonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
