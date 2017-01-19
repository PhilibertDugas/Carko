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
import SCLAlertView

class FindParkingViewController: UIViewController {
    @IBOutlet var popupView: MarkerPopup!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var resultViews: UIView!
    @IBOutlet var searchStack: UIView!

    var locationSearchTable: LocationSearchTableViewController!

    var blurView: UIVisualEffectView!
    var popupBlur: UIVisualEffectView!
    var searchResultView: UIView!

    let locationManager = CLLocationManager()
    var firstZoom = true

    var tabBar: UITabBar!
    var bookParkingVC: BookParkingViewController!
    var animator: ARNTransitionAnimator!

    var selectedParking: Parking!

    @IBAction func annotationTapped(_ sender: Any) {
        self.present(self.bookParkingVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self

        self.prepareAnimation()
        self.setupAnimator()
        self.setupSearchBar()
        self.blurMap()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.popupView.isHidden = true

        let customer = UserDefaults.standard.dictionary(forKey: "user")
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
        } else if AppState.shared.customer == nil {
            AppState.shared.customer = Customer.init(customer: customer!)
            self.setupFirstView()
        }
    }

    func setupFirstView() {
        let alreadyViewed = UserDefaults.standard.bool(forKey: "alreadyViewedFind")
        if alreadyViewed == false {
            let responder = SCLAlertView.init().showInfo("How it works", subTitle: "Find any parking spot on the map to see their availability and book them!", colorStyle: 0x00C441, colorTextButton: 0xFFFFFA)
            responder.setDismissBlock {
                UserDefaults.standard.set(true, forKey: "alreadyViewedFind")
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Parking.getAllParkings { (parkings, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.parkingFetched(parkings)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoginScreen" {
            let vc = segue.destination as! UINavigationController
            let entryVc = vc.viewControllers.first as! EntryViewController
            entryVc.delegate = self
        }
    }
}

extension FindParkingViewController: AuthenticatedDelegate {
    func userAuthenticated() {
        setupFirstView()
    }
}

extension FindParkingViewController {
    func setupSearchBar() {
        self.searchField.delegate = self
        self.searchField.addTarget(self, action: #selector(self.textChanged), for: UIControlEvents.editingChanged)

        self.locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "locationSearchTable") as! LocationSearchTableViewController
        self.locationSearchTable.mapView = mapView
        self.locationSearchTable.handleMapSearchDelegate = self
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

extension FindParkingViewController: UITextFieldDelegate {
    func textChanged() {
        locationSearchTable.updateSearchs(for: self.searchField.text)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.blurView = UIVisualEffectView.init(effect: effect)
        self.blurView.frame = mapView.bounds
        self.mapView.addSubview(blurView)

        self.searchResultView = UIView.init(frame: self.resultViews.frame)
        self.locationSearchTable.view.frame = self.searchResultView.bounds
        self.searchResultView.addSubview(self.locationSearchTable.view)
        self.view.insertSubview(self.searchResultView, aboveSubview: self.mapView)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.blurView.removeFromSuperview()
        self.searchResultView.removeFromSuperview()
    }
}

extension FindParkingViewController: MKMapViewDelegate {
    func parkingFetched(_ parkings: [(Parking)]) {
        self.mapView.removeAnnotations(mapView.annotations)
        let now = Date.init()
        for parking in parkings {
            //if parking.isComplete && parking.scheduleAvailable(now) {
            if parking.scheduleAvailable(now) {
                let annotation = ParkingAnnotation.init(parking: parking)
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    func blurMap() {
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let statusBarBlur = UIVisualEffectView.init(effect: effect)
        let searchBarBlur = UIVisualEffectView.init(effect: effect)
        statusBarBlur.frame = CGRect.init(x: 0.0, y: 0.0, width: view.bounds.width, height: 20.0)
        searchBarBlur.frame = searchStack.frame
        mapView.addSubview(statusBarBlur)
        mapView.addSubview(searchBarBlur)
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
        if self.popupBlur != nil {
            self.popupBlur.removeFromSuperview()
        }

        UIView.animate(withDuration: 0.15, animations: {
            self.popupView.frame.origin.y = self.tabBar.frame.origin.y
        })
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingAnnotation {
            let annotationView = ParkingAnnotationView.init(annotation: annotation, reuseIdentifier: nil)
            return annotationView
        }

        return nil
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let av = self.mapView.view(for: self.mapView.userLocation)
        av?.isEnabled = false
    }
}

extension FindParkingViewController: HandleMapSearch {
    func selectedPlacemark(placemark: MKPlacemark){
        let region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 800, 800)
        mapView.setRegion(region, animated: true)
        self.searchField.endEditing(true)
    }
}
