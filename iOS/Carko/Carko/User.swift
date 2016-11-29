//
//  User.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-13.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth

class User: NSObject {
    let notificationCenter = NotificationCenter.default

    var email: String
    var password: String?
    var firstName: String?
    var lastName: String?
    var uid: String?
    var id: Int?

    var parkings: [(Parking)]?
    var reservations: [(Reservation)]?
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        super.init()
    }
    
    init(email: String, password: String, firstName: String, lastName: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        super.init()
    }

    init(email: String, firstName: String, lastName: String, id: Int) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        super.init()
    }

    convenience init(user: [String: Any]) {
        let email = user["email"] as! String
        let firstName = user["first_name"] as! String
        let lastName = user["last_name"] as! String
        let id = user["id"] as! Int

        self.init(email: email, firstName: firstName, lastName: lastName, id: id)

        self.parkings = []
        for parkingDict in user["parkings"] as! NSArray {
            let parking = Parking.init(parking: parkingDict as! [String:Any])
            self.parkings?.append(parking)
        }
        
        self.reservations = []
        for reservationDict in user["reservations"] as! NSArray {
            let reservation = Reservation.init(reservation: reservationDict as! [String : Any])
            self.reservations?.append(reservation)
        }
    }
    
    func toDictionnary() -> [String : Any] {
        return ["customer": [
                "email": email,
                "first_name": firstName!,
                "last_name": lastName!,
                "firebase_id": uid!
            ]
        ]
    }
    
    func logIn() {
        FIRAuth.auth()?.signIn(withEmail: self.email, password: self.password!, completion: { (user, error) in
            if error != nil {
                self.postLoginError(error!)
            } else if let user = user {
                self.uid = user.uid
                self.notificationCenter.post(name: Notification.Name.init("UserLoggedIn"), object: nil, userInfo: nil)
            }
        })
    }
    
    func register() {
        FIRAuth.auth()?.createUser(withEmail: email, password: password!, completion: { (user, error) in
            if error != nil {
                self.postRegisterError(error!)
            } else {
                self.uid = user?.uid
                CarkoAPIClient.sharedClient.postUser(user: self, complete: { (error) in
                    if error != nil {
                        try! FIRAuth.auth()!.signOut()
                        self.postRegisterError(error!)
                    } else {
                        self.notificationCenter.post(name: Notification.Name.init("UserRegistered"), object: nil, userInfo: nil)
                    }
                })
            }
        })
    }

    class func getUser(complete: @escaping (User?, Error?) -> Void) {
        CarkoAPIClient.sharedClient.getUser(complete: complete)
    }
    
    private func postLoginError(_ error: Error) {
        self.notificationCenter.post(name: Notification.Name.init("UserLoggedInError"), object: nil, userInfo: ["data": error.localizedDescription])
    }
    
    private func postRegisterError(_ error: Error) {
        self.notificationCenter.post(name: Notification.Name.init("UserRegisteredError"), object: nil, userInfo: ["data": error.localizedDescription])
    }
}
