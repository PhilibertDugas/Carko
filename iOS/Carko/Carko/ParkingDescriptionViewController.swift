//
//  ParkingDescriptionViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

protocol ParkingDescriptionDelegate: class
{
    func userDidChangeDescription(value: String)
}

class ParkingDescriptionViewController: UIViewController {
    
    @IBOutlet weak var descriptionText: UITextView!
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ParkingDescriptionDelegate? = nil
    var parkingDescription: String?
    
    @IBAction func saveChange(_ sender: AnyObject) {
        
        delegate?.userDidChangeDescription(value: descriptionText.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelChange(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionText.text = parkingDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
