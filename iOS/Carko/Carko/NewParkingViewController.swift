//
//  ShareMapViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class NewParkingViewController: UIViewController {

    @IBOutlet var addButton: UIButton!
    
    var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var currentPlace: GMSPlace?
    var newParking: Parking?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.isHidden = true
        setupLocationManager()
        setupSearchBar()
    }

    func setupSearchBar() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        searchController?.searchBar.frame = CGRect.init(x: 0, y: 0, width: 250.0, height: 44.0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: (searchController?.searchBar)!)

        self.definesPresentationContext = true
        
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.modalPresentationStyle = UIModalPresentationStyle.popover
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        let currentMapCoordinate = mapView.camera.target
        let newAvailabilityInfo = ParkingAvailabilityInfo.init()
        self.newParking = Parking.init(latitude: currentMapCoordinate.latitude, longitude: currentMapCoordinate.longitude, photoURL: URL.init(string: "http://google.com")!, address: (currentPlace?.name)!, price: 1.0, parkingDescription: "", availabilityInfo: newAvailabilityInfo)
        
        self.performSegue(withIdentifier: "newParkingSchedule", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "newParkingSchedule" {
            let destinationViewController = segue.destination as! ParkingAvailabilityViewController
            destinationViewController.parkingAvailability = self.newParking?.availabilityInfo
            destinationViewController.delegate = self
        }
    }
}

// Parking delegates

extension NewParkingViewController: ParkingAvailabilityDelegate {
    func userDidChangeAvailability(value: ParkingAvailabilityInfo) {
        newParking?.availabilityInfo = value
        newParking?.persist()
        NotificationCenter.default.post(name: Notification.Name.init("parkingListUpdated"), object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
}



// Geolocation Delegates

extension NewParkingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentCoordinate = manager.location?.coordinate {
            let camera = GMSCameraPosition.camera(withLatitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude, zoom: 15.0)
            mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
            mapView.delegate = self
            view.insertSubview(mapView, at: 0)
            locationManager.stopUpdatingLocation()
        }
    }
}

extension NewParkingViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        self.searchController?.isActive = false
        
        self.currentPlace = place
        let newCam = GMSCameraUpdate.setTarget(place.coordinate, zoom: 19.0)
        self.mapView.mapType = kGMSTypeSatellite
        
        self.mapView.animate(with: newCam)
        self.view.insertSubview(addButton, aboveSubview: mapView)
        self.addButton.isHidden = false
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
        didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: \(error)")
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension NewParkingViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        recenterMarkerInView(newMapView: mapView)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        recenterMarkerInView(newMapView: mapView)
    }
    
    func recenterMarkerInView(newMapView: GMSMapView) {
        let center = newMapView.convert(newMapView.center, from: self.mapView)
        newMapView.clear()
        let marker = GMSMarker.init()
        marker.appearAnimation = kGMSMarkerAnimationNone
        marker.position = newMapView.projection.coordinate(for: center)
        marker.map = newMapView
    }
}
