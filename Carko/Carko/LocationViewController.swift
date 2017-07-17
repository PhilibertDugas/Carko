import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

protocol ParkingLocationDelegate {
    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class LocationViewController: UIViewController {
    @IBOutlet var addButton: UIButton!
    @IBOutlet var searchStack: UIView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var resultView: UIView!
    @IBOutlet var searchStackTopConstraint: NSLayoutConstraint!
    @IBOutlet var helperText: RoundedCornerView!

    var delegate: ParkingLocationDelegate?

    var gmsMapView: GMSMapView!
    var searchResultView: UIView!
    var locationSearchTable: LocationSearchTableViewController!
    var firstSearch = true

    var newParking: Bool = false
    var parking: Parking!
    var selectedPin: GMSPlace!
    var pinImage: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchStackTopConstraint.constant = (self.view.frame.height / 2) - (self.searchStack.frame.height / 2) - 35

        addButton.isHidden = true

        self.gmsMapView = GMSMapView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        gmsMapView.mapType = .hybrid
        self.view.insertSubview(gmsMapView, at: 1)

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.newParking && self.selectedPin != nil {
            updateParking()
            delegate?.userDidChooseLocation(address: parking.address, latitude: parking.latitude, longitude: parking.longitude)
        }
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        updateParking()
        self.performSegue(withIdentifier: "pushAvailability", sender: nil)
    }

    func updateParking() {
        guard let address = self.selectedPin.formattedAddress else { return }

        let currentMapCoordinate = gmsMapView.camera.target
        let latitude = currentMapCoordinate.latitude
        let longitude = currentMapCoordinate.longitude

        parking.address = address
        parking.latitude = latitude
        parking.longitude = longitude
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
        self.view.insertSubview(self.searchResultView, aboveSubview: self.gmsMapView)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if selectedPin != nil {
            self.helperText.isHidden = false
            self.searchStack.isHidden = true

            self.gmsMapView.subviews.forEach({ (view) in
                if let visualEffect = view as? UIVisualEffectView {
                    visualEffect.removeFromSuperview()
                }
            })
        }
        self.searchResultView.removeFromSuperview()
    }

    func blurMap() {
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView.init(effect: effect)
        blurView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        gmsMapView.addSubview(blurView)
    }

    func blurSearchBar() {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let searchBarBlur = UIVisualEffectView.init(effect: effect)
        searchBarBlur.frame = searchStack.frame
        gmsMapView.addSubview(searchBarBlur)
    }
}

extension LocationViewController: HandleMapSearch {
    func selectedPlace(place: GMSPlace) {
        self.selectedPin = place

        if let imageView = self.pinImage {
            imageView.removeFromSuperview()
        }
        let image = UIImage.init(named: "pin-available")
        self.pinImage = UIImageView.init(image: image)
        self.pinImage!.center = self.gmsMapView.center
        self.gmsMapView.addSubview(self.pinImage!)

        let camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 20.0)
        gmsMapView.camera = camera

        if self.newParking { addButton.isHidden = false }
        self.searchField.endEditing(true)
    }
}
