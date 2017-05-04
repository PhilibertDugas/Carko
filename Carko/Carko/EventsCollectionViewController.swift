//
//  EventsCollectionViewController.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-19.
//  Copyright © 2017 QH4L. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import FirebaseAuth
import AVFoundation


class EventsCollectionViewController: UICollectionViewController {

    fileprivate let reuseIdentifier = "EventCell"
    fileprivate var events: [(Event)] = []
    fileprivate var selectedEvent: Event!
    fileprivate let activityView: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView?.collectionViewLayout as? ApyaLayout {
            layout.delegate = self
        }
        self.navigationController?.navigationBar.isHidden = true
        self.activityView.frame = CGRect.init(x: (self.view.frame.size.width / 2) - 80, y: self.view.frame.size.height / 2, width: 80.0, height: 80.0)
        self.activityView.isHidden = true
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(self.activityView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.customer != nil {
            userAuthenticated()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        let customer = AppState.shared.cachedCustomer()
        if FIRAuth.auth()?.currentUser == nil || customer == nil {
            self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
        } else if AppState.shared.customer == nil {
            AppState.shared.cacheCustomer(Customer.init(customer: customer!))
            self.userAuthenticated()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoginScreen" {
            let vc = segue.destination as! UINavigationController
            let entryVc = vc.viewControllers.first as! EntryViewController
            entryVc.delegate = self
        } else if segue.identifier == "showEvent" {
            let vc = segue.destination as! FindParkingViewController
            vc.event = self.selectedEvent
        }
    }

    fileprivate func fetchEvents() {
        self.activityView.startAnimating()
        self.activityView.isHidden = false
        Event.getAllEvents { (events, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.events = events
                self.collectionView?.reloadData()
            }
            self.activityView.isHidden = true
            self.activityView.stopAnimating()
        }
    }
}

extension EventsCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.events.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.event = self.events[indexPath.row]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedEvent = self.events[indexPath.row]
        self.performSegue(withIdentifier: "showEvent", sender: nil)
    }
}

extension EventsCollectionViewController: AuthenticatedDelegate {
    func userAuthenticated() {
        let currentUser = FIRAuth.auth()?.currentUser
        currentUser?.getTokenForcingRefresh(true, completion: { (idToken, error) in
            if let error = error {
                print("\(error.localizedDescription)")
                self.performSegue(withIdentifier: "showLoginScreen", sender: nil)
            } else if let token = idToken {
                AppState.shared.authToken = token
                self.fetchEvents()
            }
        })
    }
}

extension EventsCollectionViewController: ApyaLayoutDelegate {
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let event = self.events[indexPath.item]
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        if let url = event.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            let imageView = UIImageView.init()
            imageView.sd_setImage(with: imageReference, placeholderImage: UIImage.init(named: "placeholder-1"), completion: { (image, error, cache, reference) in
                UIView.animate(withDuration: 0.3, animations: { 
                    self.collectionView?.collectionViewLayout.invalidateLayout()
                })
            })
            let rect = AVMakeRect(aspectRatio: imageView.image!.size, insideRect: boundingRect)
            return rect.size.height
        } else {
            return (self.collectionView?.frame.size.height)! / 4
        }
    }

    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let annotationPadding = CGFloat(4)
        let annotationHeaderHeight = CGFloat(17)
        let event = events[indexPath.item]
        let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        let commentHeight = event.heightForLabel(font: font, width: width)
        let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
        return height
    }

}
