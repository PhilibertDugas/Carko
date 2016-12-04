//
//  parkingTableViewController.swift
//  Carko
//
//  Created by Guillaume Lalande on 2016-10-12.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseStorage

class ParkingInfoViewController: UIViewController {

    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var helperImageView: UIImageView!
    @IBOutlet var helperImageLabel: UILabel!

    @IBOutlet var streetAddressLabel: UILabel!
    @IBOutlet var postalAddressLabel: UILabel!

    @IBOutlet var timeOfDayLabel: UILabel!
    @IBOutlet var daysAvailableLabel: UILabel!

    @IBOutlet var parkingRate: UILabel!
    @IBOutlet var parkingDescriptionLabel: UILabel!
    
    @IBOutlet var addressCollection: UIView!
    @IBOutlet var descriptionCollection: UIView!
    @IBOutlet var availabilityCollection: UIView!
    @IBOutlet var ratesCollection: UIView!
    
    var parking: Parking?

    let imagePicker = UIImagePickerController.init()
    let storageReference = FIRStorage.storage().reference(forURL: "gs://carko-1475431423846.appspot.com")

    @IBAction func cancelTapped(_ sender: Any) {
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
                NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    @IBAction func tappedAddPhotos(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func tappedLocation(_ sender: Any) {
        performSegue(withIdentifier: "ChangeLocation", sender: nil)
    }

    @IBAction func tappedDescription(_ sender: Any) {
        performSegue(withIdentifier: "ChangeDescription", sender: nil)
    }

    @IBAction func tappedAvailability(_ sender: Any) {
        performSegue(withIdentifier: "ChangeAvailability", sender: nil)
    }

    @IBAction func tappedRates(_ sender: Any) {
        performSegue(withIdentifier: "ChangeRates", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        setupCollectionViews()
        initializeParking()
        loadParkingPicture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            self.parking = Parking.init(latitude: CLLocationDegrees.init(75), longitude: CLLocationDegrees.init(-135), photoURL: URL.init(string: ""), address: "Select a location", price: 1.0, pDescription: "", isAvailable: true, availabilityInfo: newAvailabilityInfo, customerId: (AppState.sharedInstance.currentUser?.id)!)
        }
    }

    func loadParkingPicture() {
        // meh maybe not here
        if let url = self.parking?.photoURL {
            if let data = try? Data(contentsOf: url) {
                let image = UIImage(data: data)!
                displayImage(image: image)
            }
        }
    }

    func displayImage(image: UIImage) {
        self.parkingImageView.image = image
        self.parkingImageView.alpha = 1.0
        self.helperImageView.isHidden = true
        self.helperImageLabel.isHidden = true
    }

    func setupCollectionViews() {
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
            let destinationVC = segue.destination as! ParkingLocationViewController
            destinationVC.delegate = self
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

extension ParkingInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            parkingImageView.contentMode = UIViewContentMode.scaleAspectFit
            displayImage(image: image)
            // make a spinner or something
            uploadImage()
            dismiss(animated: true, completion: nil)
        }
    }

    func uploadImage() {
        var path = ""
        if let id = parking?.id {
            path = "parking_\(id)_\(Date.init())"
        } else {
            path = "user_\(AppState.sharedInstance.currentUser?.id!)_\(Date.init())"
        }

        let data = UIImageJPEGRepresentation(parkingImageView.image!, 0.8)!
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        self.storageReference.child(path).put(data, metadata: metadata).observe(FIRStorageTaskStatus.success) { (snapshot) in
            if let metadata = snapshot.metadata {
                if let url = metadata.downloadURL() {
                    self.parking?.photoURL = url
                }
            }
           // success or something + remove spinner
        }
    }
}

extension ParkingInfoViewController: UINavigationControllerDelegate {
}
