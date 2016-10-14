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
                self.uid = user?.uid
                User.ref.child("users").child(self.uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let user = snapshot.value! as! [String : Any]
                    self.firstName = user["firstName"] as? String
                    self.lastName = user["lastName"] as? String
                    self.notificationCenter.post(name: Notification.Name.init("UserLoggedIn"), object: nil, userInfo: nil)
                })
            }
        })
    }
    
    func register() {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("There was an error creating the user")
            } else {
                self.uid = user?.uid
                let newUser = ["\(self.uid!)": ["firstName": self.firstName!, "lastName": self.lastName!]] as [String : Any]
                User.ref.child("users").updateChildValues(newUser)
                self.notificationCenter.post(name: Notification.Name.init("UserRegistered"), object: nil, userInfo: nil)
            }
        })
    }
}
