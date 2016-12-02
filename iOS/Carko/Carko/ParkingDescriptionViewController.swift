//
//  ParkingDescriptionViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

protocol ParkingDescriptionDelegate: class {
    func userDidChangeDescription(value: String)
}

class ParkingDescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionText: UITextView!
    
    weak var delegate: ParkingDescriptionDelegate? = nil
    var parkingDescription: String?
    
    @IBAction func saveChange(_ sender: AnyObject) {
        delegate?.userDidChangeDescription(value: descriptionText.text)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionText.text = parkingDescription
    }
}

extension ParkingDescriptionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
