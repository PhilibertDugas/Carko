import UIKit
import MapKit

protocol ParkingLocationDelegate {
    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class LocationViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var searchStack: UIView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var resultView: UIView!
    @IBOutlet var searchStackTopConstraint: NSLayoutConstraint!

    var delegate: ParkingLocationDelegate?

    let locationManager = CLLocationManager()

    var blurView: UIVisualEffectView!
    var searchResultView: UIView!
    var locationSearchTable: LocationSearchTableViewController!
    var firstSearch = true

    var newParking: Bool = false
    var parking: Parking!
    var selectedPin: MKPlacemark!
    var pinImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchStackTopConstraint.constant = (self.view.frame.height / 2) - 40

        if !newParking {
            addButton.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState.normal)
        }

        addButton.isHidden = true
        mapView.mapType = MKMapType.satellite

        self.setupLocationManager()
        self.setupSearchBar()
        self.blurMap()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushAvailability" {
            let vc = segue.destination as! AvailabilityViewController
            vc.parking = parking
            vc.newParking = true
        }
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        updateParking()
        if newParking {
            self.performSegue(withIdentifier: "pushAvailability", sender: nil)
        } else {
            delegate?.userDidChooseLocation(address: parking.address, latitude: parking.latitude, longitude: parking.longitude)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func updateParking() {
        let currentMapCoordinate = mapView.centerCoordinate
        let latitude = currentMapCoordinate.latitude
        let longitude = currentMapCoordinate.longitude
        let address = LocationSearchTableViewController.parseAddress(selectedItem: selectedPin!)
        parking.address = address
        parking.latitude = latitude
        parking.longitude = longitude
        parking.price = 0.0
    }
}

extension LocationViewController {
    func setupSearchBar() {
        self.searchField.delegate = self
        self.searchField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)

        self.locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "locationSearchTable") as! LocationSearchTableViewController
        self.locationSearchTable.lightText = true
        self.locationSearchTable.handleMapSearchDelegate = self
    }
}

extension LocationViewController: UITextFieldDelegate {
    func textChanged() {
        locationSearchTable.updateSearchs(for: self.searchField.text)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if firstSearch {
            self.searchStackTopConstraint.constant = 16
            UIView.animate(withDuration: 1.0, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (complete) in
                if complete {
                    self.firstSearch = false
                    self.blurSearchBar()
                }
            })
        } else {
            if selectedPin != nil {
                self.blurMap()
            }
        }

        self.searchResultView = UIView.init(frame: self.resultView.frame)
        self.locationSearchTable.view.frame = self.searchResultView.bounds
        self.searchResultView.addSubview(self.locationSearchTable.view)
        self.view.insertSubview(self.searchResultView, aboveSubview: self.mapView)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if selectedPin != nil {
            self.blurView.removeFromSuperview()
        }
        self.searchResultView.removeFromSuperview()
    }

    func blurMap() {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.blurView = UIVisualEffectView.init(effect: effect)
        self.blurView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.mapView.addSubview(blurView)
    }

    func blurSearchBar() {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let searchBarBlur = UIVisualEffectView.init(effect: effect)
        searchBarBlur.frame = searchStack.frame
        mapView.addSubview(searchBarBlur)
    }
}

extension LocationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension LocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 800, 800)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        super.displayErrorMessage(error.localizedDescription)
    }
}

extension LocationViewController: HandleMapSearch {
    func selectedPlacemark(placemark: MKPlacemark) {
        self.selectedPin = placemark

        if let imageView = self.pinImage {
            imageView.removeFromSuperview()
        }
        let image = UIImage.init(named: "pin-available")
        self.pinImage = UIImageView.init(image: image)
        self.pinImage!.center = self.mapView.center
        self.mapView.addSubview(self.pinImage!)

        let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, CLLocationDistance.init(15), CLLocationDistance.init(15))
        mapView.setRegion(region, animated: true)
        addButton.isHidden = false
        self.searchField.endEditing(true)
    }
}
