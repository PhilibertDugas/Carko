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
    
    func logIn() {
        FIRAuth.auth()?.signIn(withEmail: self.email, password: self.password, completion: { (user, error) in
            if error != nil {
                
            } else {
                print("Ok !")
            }
        })
    }
    
    func register() {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("There was an error creating the user")
            } else {
                print("Ok ! Registered")
                self.notificationCenter.post(name: Notification.Name.init("UserRegistered"), object: nil, userInfo: nil)
            }
        })
    }
}
