//
//  ShareViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    @IBOutlet weak var ParkingTableView: UITableView!
    @IBOutlet weak var Edit: UIBarButtonItem!
    @IBOutlet weak var AddButton: UIBarButtonItem!
    
    var parkingList = [Parking]()
    var isEditingAvailability = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editingParking(_ sender: AnyObject) {
    
        if !isEditingAvailability
        {
            Edit.title = "Done"
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
            isEditingAvailability = true
            ParkingTableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
        }
        else
        {
            Edit.title = "Edit"
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
            isEditingAvailability = false
            ParkingTableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
        }
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

extension ShareViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ParkingTableView.dequeueReusableCell(withIdentifier: "parkingCell", for: indexPath) as! ParkingTableViewCell
        
        cell.address.text = parkingList[indexPath.row].address
        
        if !isEditingAvailability
        {
            cell.availabilitySwitch.isHidden = true
        }
        else
        {
            cell.availabilitySwitch.isHidden = false
        }
        
        return cell
    }
}
