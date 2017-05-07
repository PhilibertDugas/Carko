//
//  NewPhotoViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-07.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorage
import SCLAlertView

class NewPhotoViewController: UIViewController {
    @IBOutlet var parkingImageView: UIImageView!
    @IBOutlet var helperImageView: UIImageView!
    @IBOutlet var helperImageLabel: UILabel!
    @IBOutlet var uploadIndicator: UIActivityIndicatorView!
    @IBOutlet var descriptionText: UILabel!
    @IBOutlet var mainButton: RoundedCornerButton!

    var parking: Parking!
    let imagePicker = UIImagePickerController.init()

    @IBAction func tappedPhoto(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func tappedSave(_ sender: Any) {
        if AppState.shared.customer.accountId != nil {
            parking.isComplete = true
        }
        parking.persist { (error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else {
                NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
                self.displaySuccessMessage()
            }
        }
    }

    func displaySuccessMessage() {
        let responder = SCLAlertView.init().showSuccess(NSLocalizedString("Congratulations", comment: ""), subTitle: NSLocalizedString("You just listed a parking", comment: ""))
        responder.setDismissBlock {
            let _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.descriptionText.text = NSLocalizedString("Enter a description...", comment: "")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parking.pDescription
            destinationVC.delegate = self
        }
    }
}

extension NewPhotoViewController: ParkingDescriptionDelegate {
    func userDidChangeDescription(value: String) {
        self.descriptionText.text = value
        parking.pDescription = value
    }
}

extension NewPhotoViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            parkingImageView.image = image
            displayImage(alpha: 0.4)
            uploadImage()
            dismiss(animated: true, completion: nil)
        }
    }

    func uploadImage() {
        self.uploadIndicator.startAnimating()
        let path = "user_\(AppState.shared.customer.id)_\(Date.init())"
        let data = UIImageJPEGRepresentation(parkingImageView.image!, 0.8)!
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        AppState.shared.storageReference.child(path).put(data, metadata: metadata).observe(FIRStorageTaskStatus.success) { (snapshot) in
            if let metadata = snapshot.metadata {
                if let url = metadata.downloadURL() {
                    self.parking.photoURL = url
                    self.uploadIndicator.stopAnimating()
                    self.displayImage(alpha: 1.0)
                    self.mainButton.isEnabled = true
                    self.mainButton.alpha = 1.0
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

extension NewPhotoViewController: UINavigationControllerDelegate {}
