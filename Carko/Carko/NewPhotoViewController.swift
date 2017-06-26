//
//  NewPhotoViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-01-07.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorage
import NohanaImagePicker
import Photos

class NewPhotoViewController: UIViewController {
    @IBOutlet var buttonView: UIView!
    @IBOutlet var buttonIndicator: UIActivityIndicatorView!
    @IBOutlet var mainButton: SmallRoundedCornerButton!
    @IBOutlet var addPhotoLabel: UILabel!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var descriptionView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var bigPlusButton: UIButton!
    @IBOutlet var editPhotosLabel: UILabel!
    @IBOutlet var addDescriptionButton: SmallRoundedCornerButton!

    var parking: Parking!
    var parkingImages: [(UIImage)] = []
    var manager: PopupManager!
    let imagePicker = NohanaImagePickerController.init()
    let photoCellIdentifier = "ParkingPhotoCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // on iPhone SE in french, the buttons label are too big
        self.mainButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.addDescriptionButton.titleLabel?.adjustsFontSizeToFitWidth = true

        self.buttonView.isHidden = true
        self.buttonIndicator.isHidden = true
        self.photoCollectionView.isHidden = true
        self.descriptionView.isHidden = true
        self.imagePicker.delegate = self
        self.navigationController?.navigationBar.clipsToBounds = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parking.pDescription
            destinationVC.delegate = self
        } else if segue.identifier == "ChangePhotos" {
            let destinationVC = segue.destination as! PhotoEditCollectionViewController
            destinationVC.parking = parking
            destinationVC.delegate = self
            destinationVC.usingImages = true
            destinationVC.parkingImages = self.parkingImages
        }
    }

    @IBAction func tappedDescription(_ sender: Any) {
        self.performSegue(withIdentifier: "showDescription", sender: nil)
    }

    @IBAction func tappedPhoto(_ sender: Any) {
        imagePicker.maximumNumberOfSelection = 6
        imagePicker.numberOfColumnsInPortrait = 3
        ColorConfig.backgroundColor = UIColor.secondaryViewsBlack
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func tappedSave(_ sender: Any) {
        if AppState.shared.customer.accountId != nil {
            parking.isComplete = true
        }
        if self.parkingImages.count != self.parking.multiplePhotoUrls.count {
            self.uploadImages()
        } else {
            self.parking.photoURL = self.parking.multiplePhotoUrls.first 
            self.saveParking()
        }
    }
}

extension NewPhotoViewController: ParkingDescriptionDelegate {
    func userDidChangeDescription(value: String) {
        self.parking.pDescription = value

        self.addDescriptionButton.isHidden = true
        self.descriptionView.isHidden = false
        self.descriptionLabel.text = value
        self.descriptionLabel.sizeToFit()

        self.mainButton.isEnabled = true
        self.mainButton.isHidden = false
        self.buttonView.isHidden = false
    }
}

extension NewPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.parkingImages.count {
        case 1:
            return 1
        case 2...3:
            return 2
        case 4...6:
            return 3
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if self.parkingImages.count == 2 {
                return 1
            } else if self.parkingImages.count == 3 {
                return 2
            } else {
                return 1
            }
        case 2:
            return self.parkingImages.count - 2
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! ParkingPhotoCollectionViewCell
        switch indexPath.section {
        case 0:
            cell.parkingImageView.image = self.parkingImages[indexPath.row]
            break
        case 1:
            cell.parkingImageView.image = self.parkingImages[1 + indexPath.row]
            break
        case 2:
            cell.parkingImageView.image = self.parkingImages[2 + indexPath.row]
            break
        default:
            break
        }
        cell.layer.cornerRadius = 10
        return cell
    }
}

extension NewPhotoViewController: NohanaImagePickerControllerDelegate {
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]) {
        self.parkingImages.removeAll()
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true

        for asset in pickedAssts {
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option, resultHandler: { (result, info) in
                self.parkingImages.append(result!)
            })
        }

        dismiss(animated: true) {
            self.addPhotoLabel.isHidden = true
            self.bigPlusButton.isHidden = true
            self.photoCollectionView.isHidden = false
            self.editPhotosLabel.isHidden = false
            self.photoCollectionView.reloadData()
            self.addDescriptionButton.isHidden = false
        }
    }

    func uploadImages() {
        let date = Date.init()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        self.buttonIndicator.isHidden = false
        self.buttonIndicator.startAnimating()
        self.parking.multiplePhotoUrls = []
        for (index, image) in self.parkingImages.enumerated() {
            let path = "user_\(AuthenticationHelper.getCustomer().id)_\(date)_\(index)"
            let data = UIImageJPEGRepresentation(image, 0.8)!
            AppState.shared.storageReference.child(path).putData(data, metadata: metadata).observe(StorageTaskStatus.success) { (snapshot) in
                if let metadata = snapshot.metadata {
                    if let url = metadata.downloadURL() {
                        if self.parking.photoURL == nil {
                            self.parking.photoURL = url
                        }

                        self.parking.multiplePhotoUrls.append(url)
                        if self.parking.multiplePhotoUrls.count == self.parkingImages.count {
                            self.saveParking()
                        }
                    }
                }
            }
        }
    }

    func saveParking() {
        self.parking.persist { (error) in
            if let error = error {
                super.displayErrorMessage(error.localizedDescription)
            } else {
                self.buttonIndicator.stopAnimating()
                self.buttonIndicator.isHidden = true
                NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
                self.displaySuccessMessage()
            }
        }
    }

    func displaySuccessMessage() {
        manager = PopupManager.init(parentView: self.view, title: Translations.t("Congratulations"), description: Translations.t("You just added a parking"))
        manager.successPopup.confirmButton.addTarget(self, action: #selector(self.dismissPopup), for: .touchUpInside)
        if AuthenticationHelper.getCustomer().accountId == nil {
            manager.successPopup.warningMessage.text = Translations.t("To list this parking, complete the 'Payout' section")
        } else {
            manager.successPopup.descriptionLabel.text = Translations.t("Your parking space is now available for rent")
            manager.successPopup.warningMessage.text = ""
        }
        manager.displayPopup()
    }

    func dismissPopup(_ sender: UIButton) {
        manager.removePopup()
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
}

extension NewPhotoViewController: PhotoEditDelegate {
    func photosWereEdited(photoUrls: [(URL)], images: [(UIImage)]) {
        self.parking.multiplePhotoUrls = photoUrls
        self.parkingImages = images
        self.photoCollectionView.reloadData()
    }
}
