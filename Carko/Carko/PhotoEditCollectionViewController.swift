//
//  PhotoEditCollectionViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-13.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import ImagePicker
import FirebaseStorage

private let reuseIdentifier = "PhotoEditCell"
private let addIdentifier = "PhotoAddCell"

protocol PhotoEditDelegate {
    func photosWereEdited(photoUrls: [(URL)], images: [(UIImage)])
}

class PhotoEditCollectionViewController: UICollectionViewController {
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var parking: Parking!
    var delegate: PhotoEditDelegate!
    var usingImages = false
    var parkingImages: [(UIImage)] = []
    var parkingUrls: [(URL)] = []

    let imagePicker = ImagePickerController.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.activityIndicator.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate.photosWereEdited(photoUrls: parkingUrls, images: self.parkingImages)
    }

    override func viewWillAppear(_ animated: Bool) {
        parkingUrls = []
        for url in self.parking.multiplePhotoUrls {
            parkingUrls.append(url)
        }
    }

    @IBAction func pressedEdit(_ sender: Any) {
        if self.isEditing {
            self.setEditing(false, animated: true)
            editButton.title = Translations.t("Edit")
        } else {
            self.setEditing(true, animated: true)
            editButton.title = Translations.t("Done")
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
            imageCount = parkingUrls.count
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
            imageCount = parkingUrls.count
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
                ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: parkingUrls[indexPath.row])
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
        self.imagePicker.imageLimit = 6 - self.parking.multiplePhotoUrls.count
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            })
        } else if authStatus == .authorized {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }

    func deletePhoto(_ sender: UIButton) {
        if self.usingImages {
            self.parkingImages.remove(at: sender.tag)
        } else {
            parkingUrls.remove(at: sender.tag)
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

extension PhotoEditCollectionViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.parkingImages.append(contentsOf: images)
        imagePicker.dismiss(animated: true) {
            self.uploadImages(self.parkingImages)
        }
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.parkingImages.append(contentsOf: images)
        imagePicker.dismiss(animated: true) {
            self.uploadImages(self.parkingImages)
        }
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func uploadImages(_ images: [(UIImage)]) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        let totalImageCount = images.count + parkingUrls.count
        let date = Date.init()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        for (index, image) in images.enumerated() {
            let path = "user_\(AuthenticationHelper.getCustomer().id)_\(date)_\(index)"
            let data = UIImageJPEGRepresentation(image, 0.8)!
            AppState.shared.storageReference.child(path).putData(data, metadata: metadata).observe(StorageTaskStatus.success) { (snapshot) in
                if let metadata = snapshot.metadata {
                    if let url = metadata.downloadURL() {
                        self.parkingUrls.append(url)
                        if self.parkingUrls.count == totalImageCount {
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.collectionView!.reloadData()
                        }
                    }
                }
            }
        }
    }
}
