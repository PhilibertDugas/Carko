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
    let notificationCenter = NotificationCenter.default

    var email: String
    var id: Int?
    var password: String?
    var firstName: String?
    var lastName: String?

    var firebaseId: String!
    var stripeId: String?

    var parkings: [(Parking)]
    var reservations: [(Reservation)]

    init(email: String, password: String) {
        self.email = email
        self.password = password
        self.parkings = []
        self.reservations = []
    }
    
    init(email: String, password: String, firstName: String, lastName: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.parkings = []
        self.reservations = []
    }

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
            "first_name": firstName!,
            "last_name": lastName!,
            "firebase_id": firebaseId!,
            "parkings": parkingsAsDict(),
            "reservations": reservationsAsDict()
        ]

        // When we register, we don't have a id yet since the record is not created
        if let id = self.id, let stripeId = self.stripeId {
            dict["id"] = id
            dict["stripe_id"] = stripeId
        }

        return dict
    }
    
    func logIn() {
        FIRAuth.auth()?.signIn(withEmail: self.email, password: self.password!, completion: { (customer, error) in
            if error != nil {
                self.postLoginError(error!)
            } else if let customer = customer {
                self.firebaseId = customer.uid
                self.notificationCenter.post(name: Notification.Name.init("CustomerLoggedIn"), object: nil, userInfo: nil)
            }
        })
    }
    
    func register() {
        FIRAuth.auth()?.createUser(withEmail: email, password: password!, completion: { (customer, error) in
            if error != nil {
                self.postRegisterError(error!)
            } else if let customer = customer {
                self.firebaseId = customer.uid
                CarkoAPIClient.shared.postCustomer(customer: self, complete: { (error) in
                    if error != nil {
                        try! FIRAuth.auth()!.signOut()
                        self.postRegisterError(error!)
                    } else {
                        self.notificationCenter.post(name: Notification.Name.init("CustomerLoggedIn"), object: nil, userInfo: nil)
                    }
                })
            }
        })
    }

    class func getCustomer(complete: @escaping (Customer?, Error?) -> Void) {
        CarkoAPIClient.shared.getCustomer(complete: complete)
    }
    
    private func postLoginError(_ error: Error) {
        self.notificationCenter.post(name: Notification.Name.init("CustomerLoggedInError"), object: nil, userInfo: ["data": error.localizedDescription])
    }
    
    private func postRegisterError(_ error: Error) {
        self.notificationCenter.post(name: Notification.Name.init("CustomerRegisteredError"), object: nil, userInfo: ["data": error.localizedDescription])
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
