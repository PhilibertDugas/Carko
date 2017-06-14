//
//  PhotoEditCollectionViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-13.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import NohanaImagePicker
import Photos
import FirebaseStorage

private let reuseIdentifier = "PhotoEditCell"
private let addIdentifier = "PhotoAddCell"

protocol PhotoEditDelegate {
    func photosWereEdited(photoUrls: [(URL)], images: [(UIImage)])
}

class PhotoEditCollectionViewController: UICollectionViewController {
    @IBOutlet var editButton: UIBarButtonItem!

    var parking: Parking!
    var delegate: PhotoEditDelegate!
    var usingImages = false
    var parkingImages: [(UIImage)] = []

    let imagePicker = NohanaImagePickerController.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.imagePicker.numberOfColumnsInPortrait = 3
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate.photosWereEdited(photoUrls: self.parking.multiplePhotoUrls, images: self.parkingImages)
    }

    @IBAction func pressedEdit(_ sender: Any) {
        if self.isEditing {
            self.setEditing(false, animated: true)
            // FIXME: Translate
            editButton.title = "Edit"
        } else {
            self.setEditing(true, animated: true)
            // FIXME: Translate
            editButton.title = "Done"
        }
        self.collectionView!.reloadData()
    }
}

extension PhotoEditCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var imageCount = 0
        if self.usingImages {
            imageCount = self.parkingImages.count
        } else {
            imageCount = self.parking.multiplePhotoUrls.count
        }
        if imageCount < 6 && self.isEditing {
            return imageCount + 1
        } else {
            return imageCount
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var imageCount = 0
        if self.usingImages {
            imageCount = self.parkingImages.count
        } else {
            imageCount = self.parking.multiplePhotoUrls.count
        }

        if indexPath.row > imageCount - 1 && self.isEditing {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addIdentifier, for: indexPath) as! PhotoAddCollectionViewCell
            cell.addButton.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
            cell.layer.cornerRadius = 10
            cell.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            UIView.animate(withDuration: 0.1) {
                cell.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParkingPhotoCollectionViewCell
            if self.usingImages {
                cell.parkingImageView.image = self.parkingImages[indexPath.row]
            } else {
                ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: self.parking.multiplePhotoUrls[indexPath.row])
            }
            cell.layer.cornerRadius = 10
            cell.parkingImageView.layer.cornerRadius = 10
            cell.parkingImageView.clipsToBounds = true
            if self.isEditing {
                addButton(cell, indexPath: indexPath)
            } else {
                removeButton(cell)
            }
            return cell
        }
    }

    func addTapped() {
        self.imagePicker.maximumNumberOfSelection = 6 - self.parking.multiplePhotoUrls.count
        self.present(self.imagePicker, animated: true, completion: nil)
    }

    func deletePhoto(_ sender: UIButton) {
        if self.usingImages {
            self.parkingImages.remove(at: sender.tag)
        } else {
            self.parking.multiplePhotoUrls.remove(at: sender.tag)
        }
        self.collectionView?.reloadData()
    }

    private func addButton(_ cell: ParkingPhotoCollectionViewCell, indexPath: IndexPath) {
        let deleteButton = UIButton.init(frame: CGRect.init(x: cell.parkingImageView.frame.origin.x - 11, y: cell.parkingImageView.frame.origin.y - 11, width: 22.0, height: 22.0))
        deleteButton.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
        deleteButton.setBackgroundImage(UIImage.init(named: "delete_icon"), for: .normal)
        deleteButton.addTarget(self, action: #selector(self.deletePhoto), for: .touchUpInside)
        deleteButton.tag = indexPath.row

        UIView.animate(withDuration: 0.1) {
            deleteButton.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            cell.contentView.addSubview(deleteButton)
        }
    }

    private func removeButton(_ cell: ParkingPhotoCollectionViewCell) {
        let _ = cell.contentView.subviews.map({ (view) -> Void in
            if view is UIButton {
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
                    view.alpha = 0.0
                }, completion: { (_) in
                    view.removeFromSuperview()
                })
            }
        })

    }
}

extension PhotoEditCollectionViewController: NohanaImagePickerControllerDelegate {
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true

        for asset in pickedAssts {
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option, resultHandler: { (result, info) in
                self.parkingImages.append(result!)
            })
        }

        self.dismiss(animated: true) { 
            self.uploadImages(self.parkingImages)
        }
    }

    // FIXME: Add indicator of loading
    func uploadImages(_ images: [(UIImage)]) {
        //self.uploadIndicator.startAnimating()
        let totalImageCount = images.count + self.parking.multiplePhotoUrls.count
        let date = Date.init()
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"

        for (index, image) in images.enumerated() {
            let path = "user_\(AuthenticationHelper.getCustomer().id)_\(date)_\(index)"
            let data = UIImageJPEGRepresentation(image, 0.8)!
            AppState.shared.storageReference.child(path).put(data, metadata: metadata).observe(FIRStorageTaskStatus.success) { (snapshot) in
                if let metadata = snapshot.metadata {
                    if let url = metadata.downloadURL() {
                        self.parking.multiplePhotoUrls.append(url)
                        if self.parking.multiplePhotoUrls.count == totalImageCount {
                            self.collectionView!.reloadData()
                        }
                    }
                }
            }
        }
    }
}
