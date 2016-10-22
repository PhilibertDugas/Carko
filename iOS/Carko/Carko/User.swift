//
//  User.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-13.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class User: NSObject {
    let notificationCenter = NotificationCenter.default
    static let ref = FIRDatabase.database().reference()
    
    var email: String
    var password: String
    var firstName: String?
    var lastName: String?
    var uid: String?
    
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
        FIRAuth.auth()?.signIn(withEmail: self.email, password: self.password, completion: { (user, error) in
            if error != nil {
                self.postLoginError(error!)
            } else if let user = user {
                self.uid = user.uid
                self.notificationCenter.post(name: Notification.Name.init("UserLoggedIn"), object: nil, userInfo: nil)
            }
        })
    }
    
    func register() {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
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
    
    private func postLoginError(_ error: Error) {
        self.notificationCenter.post(name: Notification.Name.init("UserLoggedInError"), object: nil, userInfo: ["data": error.localizedDescription])
    }
    
    private func postRegisterError(_ error: Error) {
        self.notificationCenter.post(name: Notification.Name.init("UserRegisteredError"), object: nil, userInfo: ["data": error.localizedDescription])
    }
}
