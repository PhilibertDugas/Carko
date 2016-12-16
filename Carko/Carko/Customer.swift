//
//  User.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-13.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth

class Customer: NSObject {
    var email: String
    var id: Int
    var firstName: String
    var lastName: String
    var firebaseId: String
    var stripeId: String

    var accountId: String?

    var parkings: [(Parking)]
    var reservations: [(Reservation)]

    init(email: String, firstName: String, lastName: String, id: Int, firebaseId: String, stripeId: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.firebaseId = firebaseId
        self.stripeId = stripeId
        self.parkings = []
        self.reservations = []
    }

    convenience init(customer: [String: Any]) {
        let email = customer["email"] as! String
        let firstName = customer["first_name"] as! String
        let lastName = customer["last_name"] as! String
        let id = customer["id"] as! Int
        let firebaseId = customer["firebase_id"] as! String
        let stripeId = customer["stripe_id"] as! String

        self.init(email: email, firstName: firstName, lastName: lastName, id: id, firebaseId: firebaseId, stripeId: stripeId)

        if let account = customer["account_id"] as? String {
            self.accountId = account
        }

        for parkingDict in customer["parkings"] as! NSArray {
            let parking = Parking.init(parking: parkingDict as! [String:Any])
            self.parkings.append(parking)
        }
        
        for reservationDict in customer["reservations"] as! NSArray {
            let reservation = Reservation.init(reservation: reservationDict as! [String : Any])
            self.reservations.append(reservation)
        }
    }
    
    func toDictionnary() -> [String : Any] {
        var dict: [String: Any] = [
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "firebase_id": firebaseId,
            "id": id,
            "stripe_id": stripeId,
            "parkings": parkingsAsDict(),
            "reservations": reservationsAsDict()
        ]

        if let accountId = self.accountId {
            dict["account_id"] = accountId
        }

        return dict
    }
    
    class func logIn(email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (customer, error) in
            if let error = error {
                NotificationCenter.default.post(name: Notification.Name.init("CustomerLoggedInError"), object: nil, userInfo: ["data": error.localizedDescription])
            } else {
                NotificationCenter.default.post(name: Notification.Name.init("CustomerLoggedIn"), object: nil, userInfo: nil)
            }
        })
    }
    
    class func getCustomer(complete: @escaping (Customer?, Error?) -> Void) {
        CarkoAPIClient.shared.getCustomer(complete: complete)
    }

    private func parkingsAsDict() -> [[String: Any]] {
        var dictArray: [[String: Any]] = []
        for parking in self.parkings {
            dictArray.append(parking.toDictionary())
        }
        return dictArray
    }

    private func reservationsAsDict() -> [[String: Any]] {
        var dictArray: [[String: Any]] = []
        for reservation in self.reservations {
            dictArray.append(reservation.toDictionnary())
        }
        return dictArray
    }
}

class NewCustomer: NSObject {
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var firebaseId: String!

    init(email: String, password: String, firstName: String, lastName: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }

    func toDictionary() -> [String : Any] {
        return [
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "firebase_id": firebaseId
        ]
    }

    func register() {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (customer, error) in
            if error != nil {
                self.postRegisterError(error!)
            } else if let customer = customer {
                self.firebaseId = customer.uid
                CarkoAPIClient.shared.postCustomer(customer: self, complete: { (error) in
                    if error != nil {
                        try! FIRAuth.auth()!.signOut()
                        self.postRegisterError(error!)
                    } else {
                        NotificationCenter.default.post(name: Notification.Name.init("CustomerLoggedIn"), object: nil, userInfo: nil)
                    }
                })
            }
        })
    }

    private func postRegisterError(_ error: Error) {
        NotificationCenter.default.post(name: Notification.Name.init("CustomerRegisteredError"), object: nil, userInfo: ["data": error.localizedDescription])
    }
}
