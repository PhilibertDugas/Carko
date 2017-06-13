import UIKit
import CoreLocation
import FirebaseStorage
import FirebaseStorageUI

protocol ParkingDeleteDelegate {
    func parkingDeleted()
}

class ParkingInfoViewController: UITableViewController {
    var parking: Parking!
    var deleteDelegate: ParkingDeleteDelegate!
    let photoCellIdentifier = "ParkingPhotoCell"
    let tablePhotoCellIdentifier = "TablePhotoCell"
    let labelCellIdentifier = "TableLabelCell"


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
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

    private func completeParkingDelete(error: Error?) {
        if let error = error {
            super.displayErrorMessage(error.localizedDescription)
        } else {
            self.deleteDelegate.parkingDeleted()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension ParkingInfoViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: tablePhotoCellIdentifier, for: indexPath) as! PhotoParkingTableViewCell
            cell.photoCollectionView.delegate = self
            cell.photoCollectionView.dataSource = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellIdentifier, for: indexPath) as! LabelParkingTableViewCell
            // FIXME Translate
            cell.cellTitleLabel.text = "Address"
            cell.cellContentLabel.text = parking.address
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellIdentifier, for: indexPath) as! LabelParkingTableViewCell
            // FIXME Translate
            cell.cellTitleLabel.text = "Schedule"
            cell.cellContentLabel.text = parking.availabilityInfo.daysEnumerationText()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellIdentifier, for: indexPath) as! LabelParkingTableViewCell
            // FIXME Translate
            cell.cellTitleLabel.text = "Description"
            cell.cellContentLabel.text = parking.pDescription
            cell.cellContentLabel.sizeToFit()
            return cell
        default:
            return UITableViewCell.init()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            self.performSegue(withIdentifier: "ChangeLocation", sender: nil)
            break
        case 2:
            self.performSegue(withIdentifier: "ChangeAvailability", sender: nil)
            break
        case 3:
            self.performSegue(withIdentifier: "ChangeDescription", sender: nil)
            break
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.frame.height * 0.34
        } else {
            return tableView.frame.height * 0.1
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
}

extension ParkingInfoViewController: ParkingDescriptionDelegate, ParkingAvailabilityDelegate, ParkingLocationDelegate {
    func userDidChangeDescription(value: String) {
        parking.pDescription = value
        updateParking()
    }

    func userDidChangeAvailability(value: AvailabilityInfo) {
        parking.availabilityInfo = value
        updateParking()
    }

    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        parking.address = address
        parking.latitude = latitude
        parking.longitude = longitude
        updateParking()
    }

    private func updateParking() {
        self.tableView.reloadData()
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
                    //let _ = self.navigationController?.popViewController(animated: true)
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
