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


class EventsCollectionViewController: UICollectionViewController {

    fileprivate let reuseIdentifier = "EventCell"
    fileprivate var events: [(Event)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppState.shared.customer != nil {
            fetchEvents()
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
        }
    }

    fileprivate func fetchEvents() {
        Event.getAllEvents { (events, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
            } else {
                self.events = events
                self.collectionView?.reloadData()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.events.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventCollectionViewCell
        let event = self.events[indexPath.row]
        if let url = event.photoURL {
            let imageReference = AppState.shared.storageReference.storage.reference(forURL: url.absoluteString)
            cell.image.sd_setImage(with: imageReference)
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

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
