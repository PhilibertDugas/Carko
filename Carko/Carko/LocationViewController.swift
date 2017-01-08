import UIKit
import MapKit

protocol ParkingLocationDelegate {
    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class LocationViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var progressView: UIView!

    var delegate: ParkingLocationDelegate?

    let locationManager = CLLocationManager()

    var blurView: UIVisualEffectView!
    var searchController: UISearchController!
    var selectedPin: MKPlacemark!
    var centerAnnotation: MKPointAnnotation!
    var justZoomedIn = false

    var newParking: Bool = false
    var parking: Parking!

    override func viewDidLoad() {
        super.viewDidLoad()

        if !newParking {
            progressView.isHidden = true
            addButton.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState.normal)
        }

        addButton.isHidden = true
        mapView.delegate = self

        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handlePan))
        panGesture.delegate = self;
        mapView.addGestureRecognizer(panGesture)

        setupLocationManager()
        setupSearchBar()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushRates" {
            let vc = segue.destination as! RatesViewController
            vc.parking = parking
            vc.newParking = true
        }
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        updateParking()
        if newParking {
            self.performSegue(withIdentifier: "pushRates", sender: nil)
        } else {
            delegate?.userDidChooseLocation(address: parking.address, latitude: parking.latitude, longitude: parking.longitude)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }

    func handlePan() {
        centerAnnotation?.coordinate = mapView.centerCoordinate;
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func setupSearchBar() {
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "locationSearchTable") as! LocationSearchTableViewController
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        searchController = UISearchController.init(searchResultsController: locationSearchTable)
        searchController.searchResultsUpdater = locationSearchTable

        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = NSLocalizedString("Enter your address", comment: "")
        navigationItem.titleView = searchController.searchBar

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }

    func updateParking() {
        let currentMapCoordinate = mapView.centerCoordinate
        let latitude = currentMapCoordinate.latitude
        let longitude = currentMapCoordinate.longitude
        let address = LocationSearchTableViewController.parseAddress(selectedItem: selectedPin!)
        parking.address = address
        parking.latitude = latitude
        parking.longitude = longitude
    }
}

extension LocationViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView.init(effect: effect)
        blurView.frame = mapView.bounds
        mapView.addSubview(blurView)
        navigationItem.setHidesBackButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        blurView.removeFromSuperview()
        navigationItem.setHidesBackButton(false, animated: true)
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
        print("Error \(error.localizedDescription)")
    }
}

extension LocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if selectedPin != nil && !justZoomedIn {
            centerAnnotation.coordinate = mapView.centerCoordinate
        }
        justZoomedIn = false
    }
}

extension LocationViewController: HandleMapSearch {
    func selectedPlacemark(placemark: MKPlacemark){
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        centerAnnotation = MKPointAnnotation()
        centerAnnotation.coordinate = placemark.coordinate
        mapView.addAnnotation(centerAnnotation!)

        let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, CLLocationDistance.init(15), CLLocationDistance.init(15))
        justZoomedIn = true
        mapView.mapType = MKMapType.satellite
        mapView.setRegion(region, animated: true)
        addButton.isHidden = false
    }
}
