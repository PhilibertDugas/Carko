//
//  parkingTableViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import CoreLocation

class ParkingInfoViewController: UIViewController {

    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var postalAddressLabel: UILabel!
    @IBOutlet weak var timeOfDayLabel: UILabel!
    @IBOutlet weak var daysAvailableLabel: UILabel!
    @IBOutlet weak var parkingRate: UILabel!
    @IBOutlet weak var parkingDescriptionLabel: UILabel!
    
    @IBOutlet var addressCollection: UIView!
    @IBOutlet var descriptionCollection: UIView!
    @IBOutlet var availabilityCollection: UIView!
    @IBOutlet var ratesCollection: UIView!
    
    var parking: Parking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        initializeParking()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func removeParkingTapped(_ sender: Any) {
        parking?.delete()
        self.dismiss(animated: true) {
            Parking.getCustomerParkings()
        }
    }

    @IBAction func saveParkingTapped(_ sender: Any) {
        parking?.persist(complete: { (error) in
            if let error = error {
                print("\(error)")
            } else {
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
            }
        })
    }

    func setupCollectionViews() {
        let tapLocationGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedLocation))
        let tapDescriptionGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedDescription))
        let tapAvailabilityGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedAvailability))
        let tapRatesGesture = UITapGestureRecognizer.init(target: self, action: #selector(ParkingInfoViewController.tappedRates))
        addressCollection.addGestureRecognizer(tapLocationGesture)
        descriptionCollection.addGestureRecognizer(tapDescriptionGesture)
        availabilityCollection.addGestureRecognizer(tapAvailabilityGesture)
        ratesCollection.addGestureRecognizer(tapRatesGesture)


        // TODO extract this in a custom UIView
        addressCollection.layer.borderColor = UIColor.lightGray.cgColor
        addressCollection.layer.borderWidth = CGFloat.init(1.0)

        descriptionCollection.layer.borderColor = UIColor.lightGray.cgColor
        descriptionCollection.layer.borderWidth = CGFloat.init(1.0)

        availabilityCollection.layer.borderColor = UIColor.lightGray.cgColor
        availabilityCollection.layer.borderWidth = CGFloat.init(1.0)

        ratesCollection.layer.borderColor = UIColor.lightGray.cgColor
        ratesCollection.layer.borderWidth = CGFloat.init(1.0)

    }

    func tappedLocation() {
        performSegue(withIdentifier: "ChangeLocation", sender: nil)
    }

    func tappedDescription() {
        performSegue(withIdentifier: "ChangeDescription", sender: nil)
    }

    func tappedAvailability() {
        performSegue(withIdentifier: "ChangeAvailability", sender: nil)
    }

    func tappedRates() {
        performSegue(withIdentifier: "ChangeRates", sender: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeParking()
    }

    func initializeParking() {
        if let parking = self.parking {
            streetAddressLabel.text = parking.address
            postalAddressLabel.text = parking.address

            // TODO: Not sure if this belong here
            timeOfDayLabel.text = parking.availabilityInfo.lapsOfTimeText()
            daysAvailableLabel.text = parking.availabilityInfo.daysEnumerationText()

            parkingRate.text = parking.price.asLocaleCurrency
            parkingDescriptionLabel.text = parking.pDescription
        } else {
            let newAvailabilityInfo = AvailabilityInfo.init()
            self.parking = Parking.init(latitude: CLLocationDegrees.init(75), longitude: CLLocationDegrees.init(-135), photoURL: URL.init(string: "http://google.com")!, address: "Select a location", price: 1.0, pDescription: "", isAvailable: true, availabilityInfo: newAvailabilityInfo)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NotificationCenter.default.removeObserver(self)
        
        if segue.identifier == "ChangeRates" {
            let destinationVC = segue.destination as! ParkingRatesViewController
            destinationVC.parkingRate = parking?.price
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parking?.pDescription
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeAvailability" {
            let destinationVC = segue.destination as! ParkingAvailabilityViewController
            destinationVC.parkingAvailability = parking?.availabilityInfo
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeLocation" {
            let destinationVC = segue.destination as! UINavigationController
            let locationVC = destinationVC.viewControllers.first as! ParkingLocationViewController
            locationVC.delegate = self
        }
    }
}

extension ParkingInfoViewController: ParkingRateDelegate {
    func userDidChangeRate(value: Float) {
        parking?.price = value
    }
}

extension ParkingInfoViewController: ParkingDescriptionDelegate {
    func userDidChangeDescription(value: String) {
        parking?.pDescription = value
    }
}

extension ParkingInfoViewController: ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: AvailabilityInfo) {
        parking?.availabilityInfo = value
    }
}

extension ParkingInfoViewController: ParkingLocationDelegate {
    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        parking?.address = address
        parking?.latitude = latitude
        parking?.longitude = longitude
    }
}
