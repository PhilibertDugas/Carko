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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
        } else if segue.identifier == "ChangePhotos" {
            let destinationVC = segue.destination as! PhotoEditCollectionViewController
            destinationVC.parking = self.parking
            destinationVC.delegate = self
            destinationVC.usingImages = false
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
            cell.photoCollectionView.reloadData()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellIdentifier, for: indexPath) as! LabelParkingTableViewCell
            cell.cellTitleLabel.text = Translations.t("Address")
            cell.cellContentLabel.text = parking.address
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellIdentifier, for: indexPath) as! LabelParkingTableViewCell
            cell.cellTitleLabel.text = Translations.t("Schedule")
            cell.cellContentLabel.text = parking.availabilityInfo.daysEnumerationText()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelCellIdentifier, for: indexPath) as! LabelParkingTableViewCell
            cell.cellTitleLabel.text = Translations.t("Description")
            cell.cellContentLabel.text = parking.pDescription
            cell.cellContentLabel.sizeToFit()
            return cell
        default:
            return UITableViewCell.init()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: "ChangePhotos", sender: nil)
            break
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
        return 15.0
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && AuthenticationHelper.getCustomer().accountId == nil {
            return 20.0
        }
        return 0.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && AuthenticationHelper.getCustomer().accountId == nil {
            let button = NoBorderButton.init(frame: CGRect.init(x: self.tableView.frame.width / 2, y: 0, width: self.tableView.frame.width, height: 15.0))
            button.setTitle(Translations.t("To list this parking, complete the 'Payout' section"), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10.0)
            button.setTitleColor(UIColor.accentColor, for: .normal)
            button.backgroundColor = UIColor.clear
            button.addTarget(self, action: #selector(self.addAccountTapped), for: .touchUpInside)
            return button
        }
        return nil
    }

    func addAccountTapped() {
        self.performSegue(withIdentifier: "showPayout", sender: nil)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            // 15 distance between collection view and "Edit Photos" label + 11 height for "Edit Photos"
            return (tableView.frame.height * 0.34) + 26
        } else if indexPath.section == 3 {
            return tableView.frame.height
        } else {
            return tableView.frame.height * 0.15
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
}

extension ParkingInfoViewController: ParkingDescriptionDelegate, ParkingAvailabilityDelegate, ParkingLocationDelegate, PhotoEditDelegate {
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

    func photosWereEdited(photoUrls: [(URL)], images: [(UIImage)]) {
        parking.multiplePhotoUrls = photoUrls
        updateParking()
    }

    private func updateParking() {
        self.tableView.reloadData()
        // FIXME : Hmm
        //if parking.isAvailable {
            if AuthenticationHelper.getCustomer().accountId != nil {
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
            ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: self.parking.multiplePhotoUrls[indexPath.row])
            break
        case 1:
            ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: self.parking.multiplePhotoUrls[1 + indexPath.row])
            break
        case 2:
            ImageLoaderHelper.loadImageFromUrl(cell.parkingImageView, url: self.parking.multiplePhotoUrls[2 + indexPath.row])
            break
        default:
            break
        }
        cell.layer.cornerRadius = 10
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = IndexPath.init(row: 0, section: 0)
        self.tableView.selectRow(at: index, animated: true, scrollPosition: .middle)
        self.tableView(self.tableView, didSelectRowAt: index)
    }
}
