//
//  FindParkingViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import UIKit
import ARNTransitionAnimator
import MapKit
import FirebaseStorageUI
import FirebaseAuth

class FindParkingViewController: UIViewController {
    @IBOutlet var popupView: MarkerPopup!
    @IBOutlet var mapView: MKMapView!

    var searchController: UISearchController!
    var blurView: UIVisualEffectView!

    let locationManager = CLLocationManager()
    var firstZoom = true

    var tabBar: UITabBar!
    var bookParkingVC: BookParkingViewController!
    var animator: ARNTransitionAnimator!
    var shouldDismissPopupview = true

    var selectedParking: Parking!

    @IBAction func annotationTapped(_ sender: Any) {
        self.shouldDismissPopupview = false
        self.present(self.bookParkingVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.popupView.isHidden = true
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()

        self.prepareAnimation()
        self.setupAnimator()
        self.setupSearchBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let customer = UserDefaults.standard.dictionary(forKey: "user")
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
        } else if AppState.shared.customer == nil {
            AppState.shared.customer = Customer.init(customer: customer!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isTranslucent = true
        Parking.getAllParkings { (parkings, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.parkingFetched(parkings)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isTranslucent = false
    }
}

extension FindParkingViewController {
    func setupSearchBar() {
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "locationSearchTable") as! LocationSearchTableViewController
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        searchController = UISearchController.init(searchResultsController: locationSearchTable)
        searchController.searchResultsUpdater = locationSearchTable

        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = NSLocalizedString("Search for a location", comment: "")
        navigationItem.titleView = searchController.searchBar

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
}

extension FindParkingViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView.init(effect: effect)
        blurView.frame = mapView.bounds
        mapView.addSubview(blurView)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        blurView.removeFromSuperview()
    }
}

extension FindParkingViewController: HandleMapSearch {
    func selectedPlacemark(placemark: MKPlacemark){
        let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 800, 800)
        mapView.setRegion(region, animated: true)
    }
}


extension FindParkingViewController {
    func prepareAnimation() {
        if let tabController = self.tabBarController {
            self.tabBar = tabController.tabBar
        } else {
            self.tabBar = UITabBarController.init().tabBar
        }

        self.bookParkingVC = storyboard?.instantiateViewController(withIdentifier: "bookParkingViewController") as? BookParkingViewController
        self.bookParkingVC.modalPresentationStyle = .overCurrentContext

        self.bookParkingVC.tapCloseButtonActionHandler = { _ in
            self.tabBar.frame.origin.y = self.mapView.frame.height
            self.popupView.descriptionLabel.text = self.selectedParking.address
            self.popupView.frame.origin.y = self.mapView.frame.height - self.tabBar.frame.height
        }
    }

    func setupAnimator() {
        let animation = ParkingTransitionAnimation(rootVC: self, modalVC: self.bookParkingVC)

        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(_self.bookParkingVC.view)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }

        let gestureHandler = TransitionGestureHandler(targetVC: self, direction: .top)
        gestureHandler.registerGesture(self.popupView)
        gestureHandler.panCompletionThreshold = 15.0

        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator!.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        self.bookParkingVC.transitioningDelegate = self.animator
    }
}

extension FindParkingViewController: MKMapViewDelegate {
    func parkingFetched(_ parkings: [(Parking)]) {
        self.mapView.removeAnnotations(mapView.annotations)
        let now = Date.init()
        for parking in parkings {
            if parking.isComplete && parking.scheduleAvailable(now) {
                let annotation = ParkingAnnotation.init(parking: parking)
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if firstZoom {
            firstZoom = false
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? ParkingAnnotation {
            let parking = annotation.parking
            self.selectedParking = parking
            self.bookParkingVC.parking = parking

            popupView.descriptionLabel.text = parking.address
            popupView.priceLabel.text = "\(parking.price.asLocaleCurrency)/h"

            if let url = parking.photoURL {
                let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
                popupView.imageView.sd_setImage(with: imageReference)
            }

            UIView.animate(withDuration: 0.15, animations: { 
                self.popupView.isHidden = false
                let yOrigin = self.mapView.frame.height - self.tabBar.frame.height
                self.popupView.frame.origin.y = yOrigin
            })
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if self.shouldDismissPopupview {
            UIView.animate(withDuration: 0.15, animations: {
                self.popupView.frame.origin.y = self.tabBar.frame.origin.y
            })
        } else {
            self.shouldDismissPopupview = true
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingAnnotation {
            let annotationView = MKPinAnnotationView.init()
            if annotation.parking.isAvailable {
                annotationView.pinTintColor = UIColor.red
            } else {
                annotationView.pinTintColor = UIColor.gray
            }
            return annotationView
        }
        return nil
    }
}
