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
    // Image Section
    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var helperImageView: UIImageView!
    @IBOutlet var helperImageLabel: UILabel!

    // Address Section
    @IBOutlet var streetAddressLabel: UILabel!
    @IBOutlet var postalAddressLabel: UILabel!

    // Availability Section
    @IBOutlet var timeOfDayLabel: UILabel!
    @IBOutlet var daysAvailableLabel: UILabel!

    // Rates & Description
    @IBOutlet var parkingRate: UILabel!
    @IBOutlet var parkingDescriptionLabel: UILabel!
    
    @IBOutlet var removeButton: RoundedCornerButton!
    @IBOutlet var updateButton: RoundedCornerButton!

    var parking: Parking!
    var isNewParking = true
    var validation = ["address": false, "description": false, "rates": false, "availability": false, "photo": false]
    let imagePicker = UIImagePickerController.init()

    @IBAction func removeParkingTapped(_ sender: Any) {
        if parking.isAvailable {
            parking.delete(complete: completeParkingDelete)
        } else {
            self.displayErrorMessage("You can't remove a parking while it's in use. Please wait after the parking duration")
        }
    }

    @IBAction func saveParkingTapped(_ sender: Any) {
        if isNewParking {
            if parkingIsValid() {
                parking.persist(complete: completeParkingUpdate)
            }
        } else if parking.isAvailable {
            parking.update(complete: completeParkingUpdate)
        } else {
            self.displayErrorMessage("You can't modify the details of a parking while it's in use. Please wait after the parking duration")
        }
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
        initializeParking()
        loadParkingPicture()

        if isNewParking {
            self.title = "New Parking"
            self.updateButton.setTitle("Save", for: UIControlState.normal)
        } else {
            self.title = "Edit Parking"
            self.updateButton.setTitle("Update", for: UIControlState.normal)
        }
    }

    func parkingIsValid() -> Bool{
        let fields = validation.filter { (_, value) in return !value }.map { (key, _) in return key.capitalized }
        if fields.count > 0 {
            self.displayErrorMessage("Make sure to fill the following fields: \(fields.joined(separator: ", "))")
            return false
        } else if AppState.shared.customer.accountId == nil {
            self.displayErrorMessage("Please fill out the bank information in the profile section before listing a parking")
            return false
        } else {
            return true
        }
    }

    func initializeParking() {
        if self.parking != nil {
            isNewParking = false
            for field in ["address", "availability", "rate", "description"] {
                updateLabels(field: field)
            }
        } else {
            let newAvailabilityInfo = AvailabilityInfo.init()
            self.parking = Parking.init(latitude: CLLocationDegrees.init(75), longitude: CLLocationDegrees.init(-135), photoURL: URL.init(string: ""), address: "Select a location", price: 1.0, pDescription: "", isAvailable: true, availabilityInfo: newAvailabilityInfo, customerId: AppState.shared.customer.id)
        }
    }

    func updateLabels(field: String) {
        switch field {
        case "address":
            streetAddressLabel.text = self.parking.address
            postalAddressLabel.text = self.parking.address
        case "availability":
            timeOfDayLabel.text = self.parking.availabilityInfo.lapsOfTimeText()
            daysAvailableLabel.text = self.parking.availabilityInfo.daysEnumerationText()
        case "rates":
            parkingRate.text = self.parking.price.asLocaleCurrency
        case "description":
            parkingDescriptionLabel.text = self.parking.pDescription
        default:
            print("Error, shouldn't have happened")
        }
    }

    func displayErrorMessage(_ message: String) {
        let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}


extension ParkingInfoViewController {
    func completeParkingDelete(error: Error?) {
        if let error = error {
            self.displayErrorMessage(error.localizedDescription)
        } else {
            NotificationCenter.default.post(name: Notification.Name.init("ParkingDeleted"), object: nil, userInfo: nil)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func completeParkingUpdate(error: Error?) {
        if let error = error {
            self.displayErrorMessage(error.localizedDescription)
        } else {
            NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ParkingInfoViewController: ParkingRateDelegate, ParkingDescriptionDelegate, ParkingAvailabilityDelegate, ParkingLocationDelegate {
    func userDidChangeRate(value: Float) {
        parking.price = value
        updateLabels(field: "rates")
        validation["rates"] = true
    }

    func userDidChangeDescription(value: String) {
        parking.pDescription = value
        updateLabels(field: "description")
        validation["description"] = true
    }

    func userDidChangeAvailability(value: AvailabilityInfo) {
        parking.availabilityInfo = value
        updateLabels(field: "availability")
        validation["availability"] = true
    }

    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        parking.address = address
        parking.latitude = latitude
        parking.longitude = longitude
        updateLabels(field: "address")
        validation["address"] = true
    }
}

extension ParkingInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            parkingImageView.image = image
            displayImage()
            uploadImage()
            dismiss(animated: true, completion: nil)
        }
    }

    func uploadImage() {
        var path = ""
        if let id = parking.id {
            path = "parking_\(id)_\(Date.init())"
        } else {
            path = "user_\(AppState.shared.customer.id)_\(Date.init())"
        }

        let data = UIImageJPEGRepresentation(parkingImageView.image!, 0.8)!
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        AppState.shared.storageReference.child(path).put(data, metadata: metadata).observe(FIRStorageTaskStatus.success) { (snapshot) in
            if let metadata = snapshot.metadata {
                if let url = metadata.downloadURL() {
                    self.parking.photoURL = url
                    self.validation["photo"] = true
                }
            }
           // success or something + remove spinner
        }
    }

    func loadParkingPicture() {
        if let url = self.parking.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            parkingImageView.sd_setImage(with: imageReference)
            displayImage()
        }
    }

    func displayImage() {
        self.parkingImageView.alpha = 1.0
        self.helperImageView.isHidden = true
        self.helperImageLabel.isHidden = true
    }
}

extension ParkingInfoViewController: UINavigationControllerDelegate {}
