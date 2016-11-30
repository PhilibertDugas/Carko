//
//  ShareMapViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol ParkingLocationDelegate: class {
    func userDidChooseLocation(address: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class ParkingLocationViewController: UIViewController {

    @IBOutlet var addButton: UIButton!
    @IBOutlet var mapView: MKMapView!

    var searchController: UISearchController?
    var selectedPin: MKPlacemark?
    let locationManager = CLLocationManager()
    var centerAnnotation: MKPointAnnotation?

    var justZoomedIn = false

    weak var delegate: ParkingLocationDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        addButton.isHidden = true

        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(ParkingLocationViewController.handlePan))
        panGesture.delegate = self;
        mapView.addGestureRecognizer(panGesture)

        setupSearchBar()
    }

    func handlePan() {
        centerAnnotation?.coordinate = mapView.centerCoordinate;
    }

    func setupSearchBar() {
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "locationSearchTable") as! LocationSearchTableTableViewController
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        searchController = UISearchController.init(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable

        let searchBar = searchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar

        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        let currentMapCoordinate = mapView.centerCoordinate
        delegate?.userDidChooseLocation(address: (selectedPin?.title)!, latitude: currentMapCoordinate.latitude, longitude: currentMapCoordinate.longitude)
        self.dismiss(animated: true, completion: nil)
    }
}

extension ParkingLocationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ParkingLocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance.init(15), CLLocationDistance.init(15))
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error.localizedDescription)")
    }
}

extension ParkingLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if selectedPin != nil && !justZoomedIn {
            centerAnnotation?.coordinate = mapView.centerCoordinate
        }
        justZoomedIn = false
    }
}

extension ParkingLocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        addButton.isHidden = false
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        centerAnnotation = MKPointAnnotation()
        centerAnnotation?.coordinate = placemark.coordinate

        /*annotation.title = placemark.name

        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }*/

        mapView.addAnnotation(centerAnnotation!)

        let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, CLLocationDistance.init(15), CLLocationDistance.init(15))
        justZoomedIn = true
        mapView.mapType = MKMapType.satellite
        mapView.setRegion(region, animated: true)
    }
}
