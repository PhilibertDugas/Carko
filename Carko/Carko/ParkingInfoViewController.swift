import UIKit
import CoreLocation
import FirebaseStorage
import FirebaseStorageUI

protocol ParkingDeleteDelegate {
    func parkingDeleted()
}

class ParkingInfoViewController: UIViewController {
    @IBOutlet var photoCollectionView: UICollectionView!

    @IBOutlet var streetAddressLabel: UILabel!
    @IBOutlet var parkingDescriptionLabel: UILabel!
    @IBOutlet var daysAvailableLabel: UILabel!

    var parking: Parking!
    var deleteDelegate: ParkingDeleteDelegate!
    let photoCellIdentifier = "ParkingPhotoCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoCollectionView.delegate = self
        initializeParking()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.parkingDescriptionLabel.sizeToFit()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeDescription" {
            let destinationVC = segue.destination as! ParkingDescriptionViewController
            destinationVC.parkingDescription = parking.pDescription
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeAvailability" {
            let destinationVC = segue.destination as! AvailabilityViewController
            destinationVC.parking = parking
            destinationVC.newParking = false
            destinationVC.delegate = self
        } else if segue.identifier == "ChangeLocation" {
            let destinationVC = segue.destination as! LocationViewController
            destinationVC.parking = self.parking
            destinationVC.newParking = false
            destinationVC.delegate = self
        }
    }

    @IBAction func deletedTapped(_ sender: Any) {
        if self.parking.isAvailable {
            self.parking.delete(complete: completeParkingDelete)
        } else {
            super.displayDestructiveMessage("YOUR PARKING IS CURRENTLY IN USE, ARE YOU SURE YOU WANT TO REMOVE IT?", title: "PARKING IN USE", handle: { (action) in
                self.parking.delete(complete: self.completeParkingDelete)
            })
        }

    }

    private func initializeParking() {
        for field in ["address", "availability", "description"] {
            updateLabels(field: field)
        }
    }

    fileprivate func updateLabels(field: String) {
        switch field {
        case "address":
            streetAddressLabel.text = self.parking.address
        case "availability":
            daysAvailableLabel.text = self.parking.availabilityInfo.daysEnumerationText()
        case "description":
            parkingDescriptionLabel.text = self.parking.pDescription
            parkingDescriptionLabel.sizeToFit()
        default:
            print("Error, shouldn't have happened")
        }
    }

    private func completeParkingDelete(error: Error?) {
        if let error = error {
            super.displayErrorMessage(error.localizedDescription)
        } else {
            self.deleteDelegate.parkingDeleted()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension ParkingInfoViewController: ParkingDescriptionDelegate, ParkingAvailabilityDelegate, ParkingLocationDelegate {
    func userDidChangeDescription(value: String) {
        parking.pDescription = value
        updateParking()
        updateLabels(field: "description")
    }

    func userDidChangeAvailability(value: AvailabilityInfo) {
        parking.availabilityInfo = value
        updateParking()
        updateLabels(field: "availability")
    }

    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        parking.address = address
        parking.latitude = latitude
        parking.longitude = longitude
        updateParking()
        updateLabels(field: "address")
    }

    private func updateParking() {
        // FIXME : Hmm
        //if parking.isAvailable {
            if AppState.shared.customer.accountId != nil {
                parking.isComplete = true
            }
            parking.update(complete: { (error) in
                if let error = error {
                    super.displayErrorMessage(error.localizedDescription)
                } else {
                    NotificationCenter.default.post(name: Notification.Name.init("NewParking"), object: nil, userInfo: nil)
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            })
        //} else {
        //    super.displayErrorMessage("You can't modify the details of a parking while it's in use. Please wait after the parking duration")
        //}
    }
}

extension ParkingInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.parking.multiplePhotoUrls.count {
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
            if self.parking.multiplePhotoUrls.count == 2 {
                return 1
            } else if self.parking.multiplePhotoUrls.count == 3 {
                return 2
            } else {
                return 1
            }
        case 2:
            return self.parking.multiplePhotoUrls.count - 2
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! ParkingPhotoCollectionViewCell
        switch indexPath.section {
        case 0:
            loadPicture(self.parking.multiplePhotoUrls[indexPath.row], cell: cell)
            break
        case 1:
            loadPicture(self.parking.multiplePhotoUrls[1 + indexPath.row], cell: cell)
            break
        case 2:
            loadPicture(self.parking.multiplePhotoUrls[2 + indexPath.row], cell: cell)
            break
        default:
            break
        }
        cell.layer.cornerRadius = 10
        return cell
    }

    private func loadPicture(_ url: URL, cell: ParkingPhotoCollectionViewCell) {
        let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
        cell.parkingImageView.sd_setImage(with: imageReference, placeholderImage: UIImage.init(named: "placeholder-1"))
    }
}
