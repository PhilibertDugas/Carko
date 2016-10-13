//
//  ParkingRatesViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit

protocol ParkingRateDelegate: class
{
    func userDidChangeRate(value: Float)
}

class ParkingRatesViewController: UIViewController {
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: ParkingRateDelegate? = nil
    
    @IBOutlet weak var postedRateField: UITextField!
    @IBOutlet weak var hourlyRateField: UITextField!
    @IBOutlet weak var postedRateSlider: UISlider!
    
    let appPercentageCut:Float = 0.2
    var initialRate: Float?
    
    @IBAction func hourlyRateChanged(_ sender: AnyObject) {
        
        postedRateField.text = (Float(hourlyRateField.text!)!*(1 + appPercentageCut)).asLocaleCurrency
        postedRateSlider.value = Float(postedRateField.text!)!
    }
    
    @IBAction func postedRateChanged(_ sender: AnyObject) {
        
        postedRateSlider.value = Float(postedRateField.text!)!
        hourlyRateField.text = (Float(postedRateSlider.value)*(1 - appPercentageCut)).asLocaleCurrency
    }
    
    @IBAction func postedRateSliderChanged(_ sender: AnyObject) {
        
        postedRateField.text = Float(postedRateSlider.value).asLocaleCurrency
        hourlyRateField.text = (Float(postedRateSlider.value)*(1 - appPercentageCut)).asLocaleCurrency
    }
    
    @IBAction func saveChange(_ sender: AnyObject) {
        
        delegate?.userDidChangeRate(value: Float(postedRateSlider.value).asCurrency)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelChange(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postedRateField.text = initialRate?.asLocaleCurrency
        hourlyRateField.text = (initialRate! * (1-appPercentageCut)).asLocaleCurrency
        
        postedRateSlider.value = initialRate!
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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

extension ParkingRatesViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // allow backspace
        if (string.characters.count == 0)
        {
            return true
        }
        
        if (Int(string) != nil)
        {
            return true
        }
        
        return false
    }
}
