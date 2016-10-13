//
//  ParkingAvailabilityViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class ParkingAvailabilityViewController: UIViewController {
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBOutlet weak var availabilitySelectionView: UIView!
    
    @IBAction func saveChange(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelChange(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fromTimeEditBegin(_ sender: AnyObject) {
        
        let datePicker = UIDatePicker()
        fromTextField.inputView = datePicker
    }
    
    @IBAction func toTimeEditBegin(_ sender: AnyObject) {
        
        let datePicker = UIDatePicker()
        toTextField.inputView = datePicker
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
