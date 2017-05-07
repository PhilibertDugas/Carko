//
//  NavigationViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2017-05-04.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

class NavigationViewController: UIViewController {
    
    
    @IBOutlet weak var headerView: ProfileHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //headerView.layer.cornerRadius = 7
        //headerView.layer.masksToBounds = true
        //headerView.layer.borderColor = (#colorLiteral(red: 0.8200154901, green: 0.1567437351, blue: 0.2629780173, alpha: 1)).cgColor
        //headerView.layer.borderWidth = 2.0

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
