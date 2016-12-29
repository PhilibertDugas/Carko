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

class ParkingInfoViewController: UITableViewController {
    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var helperImageView: UIImageView!
    @IBOutlet var helperImageLabel: UILabel!
    @IBOutlet var uploadIndicator: UIActivityIndicatorView!

    @IBOutlet var streetAddressLabel: UILabel!
    @IBOutlet var parkingDescriptionLabel: UILabel!
    @IBOutlet var timeOfDayLabel: UILabel!
    @IBOutlet var daysAvailableLabel: UILabel!
    @IBOutlet var parkingRate: UILabel!

    @IBOutlet var updateButton: UIBarButtonItem!

    var parking: Parking!
    var isNewParking = true
    var validation = ["address": false, "description": false, "rates": false, "availability": false, "photo": false]
    let imagePicker = UIImagePickerController.init()


    @IBAction func saveParkingTapped(_ sender: Any) {
        if isNewParking {
            if parkingIsValid() {
                parking.persist(complete: completeParkingUpdate)
            }
        } else if parking.isAvailable {
            parking.update(complete: completeParkingUpdate)
        } else {
            super.displayErrorMessage("You can't modify the details of a parking while it's in use. Please wait after the parking duration")
        }
    }

    @IBAction func tappedAddPhotos(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        initializeParking()
        loadParkingPicture()

        if isNewParking {
            self.title = "New"
            self.updateButton.title = "Create"
        } else {
            self.title = "Edit"
            self.updateButton.title = "Update"
        }
    }

    func parkingIsValid() -> Bool{
        let fields = validation.filter { (_, value) in return !value }.map { (key, _) in return key.capitalized }
        if fields.count > 0 {
            super.displayErrorMessage("Make sure to fill the following fields: \(fields.joined(separator: ", "))")
            return false
        } else if AppState.shared.customer.accountId == nil {
            super.displayErrorMessage("Please fill out the bank information in the profile section before listing a parking")
            return false
        } else {
            return true
        }
    }

    func initializeParking() {
        if self.parking != nil {
            isNewParking = false
            for field in ["address", "availability", "rates", "description"] {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeRates" {
            let destinationVC = segue.destination as! ParkingRatesViewController
            destinationVC.parkingRate = parking.price
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parking.pDescription
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeAvailability" {
            let destinationVC = segue.destination as! ParkingAvailabilityViewController
            destinationVC.parkingAvailability = parking.availabilityInfo
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
    func completeParkingUpdate(error: Error?) {
        if let error = error {
            super.displayErrorMessage(error.localizedDescription)
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
            displayImage(alpha: 0.4)
            uploadImage()
            dismiss(animated: true, completion: nil)
        }
    }

    func uploadImage() {
        self.uploadIndicator.startAnimating()
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
                    self.uploadIndicator.stopAnimating()
                    self.displayImage(alpha: 1.0)
                }
            }
        }
    }

    func loadParkingPicture() {
        if let url = self.parking.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            parkingImageView.sd_setImage(with: imageReference)
            displayImage(alpha: 1.0)
        }
    }

    func displayImage(alpha: Float) {
        self.parkingImageView.alpha = CGFloat(alpha)
        self.helperImageView.isHidden = true
        self.helperImageLabel.isHidden = true
    }
}

extension ParkingInfoViewController: UINavigationControllerDelegate {}
