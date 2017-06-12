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
import NohanaImagePicker
import Photos

class NewPhotoViewController: UIViewController {
    @IBOutlet var mainButton: RoundedCornerButton!
    @IBOutlet var addPhotoLabel: UILabel!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var bigPlusView: UIView!

    var parking: Parking!
    var parkingImages: [(UIImage)] = []
    let imagePicker = NohanaImagePickerController.init()
    let photoCellIdentifier = "ParkingPhotoCell"

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
        self.photoCollectionView.isHidden = true
        self.photoCollectionView.delegate = self
        self.imagePicker.delegate = self
        self.navigationController?.navigationBar.clipsToBounds = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parking.pDescription
            destinationVC.delegate = self
        }
    }

    @IBAction func tappedPhoto(_ sender: Any) {
        imagePicker.maximumNumberOfSelection = 6
        imagePicker.numberOfColumnsInPortrait = 3
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension NewPhotoViewController: ParkingDescriptionDelegate {
    func userDidChangeDescription(value: String) {
        parking.pDescription = value
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
            if self.parkingImages.count > 2 {
                return 2
            } else {
                return 1
            }
        case 2:
            return self.parkingImages.count - 3
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
            cell.parkingImageView.image = self.parkingImages[3 + indexPath.row]
            break
        default:
            break
        }
        cell.parkingImageView.layer.cornerRadius = 10
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat!
        switch indexPath.section {
        case 0:
            if self.parkingImages.count > 1 {
                width = 0.65 * self.photoCollectionView.frame.width
            } else {
                width = self.photoCollectionView.frame.width
                let height = self.photoCollectionView.frame.height
                return CGSize.init(width: width, height: height)
            }
            break
        case 1:
            width = 0.30 * self.photoCollectionView.frame.width
            break
        case 2:
            width = 0.13 * self.photoCollectionView.frame.width
            break
        default:
            width = self.photoCollectionView.frame.width
        }

        let height = width
        return CGSize.init(width: width, height: height!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets.init(top: 0, left: 6.0, bottom: 0, right: 6.0)
        default:
            return UIEdgeInsets.init(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)

        }
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
            self.bigPlusView.isHidden = true
            self.photoCollectionView.isHidden = false
            self.photoCollectionView.reloadData()
        }
    }

    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
    }*/
}
