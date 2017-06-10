//
//  User.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-13.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Customer {
    var email: String
    var id: Int
    var firstName: String
    var lastName: String
    var firebaseId: String
    var stripeId: String

    var vehicule: Vehicule?
    var accountId: String?
    var externalLast4Digits: String?
    var externalBankName: String?

    init(email: String, firstName: String, lastName: String, id: Int, firebaseId: String, stripeId: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.firebaseId = firebaseId
        self.stripeId = stripeId
    }

    init(customer: [String: Any]) {
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

        if let last4 = customer["bank_last_4_digits"] as? String, let bankName = customer["bank_name"] as? String {
            self.externalLast4Digits = last4
            self.externalBankName = bankName
        }

        if let vehicule = customer["vehicule"] as? [String: Any] {
            self.vehicule = Vehicule.init(vehicule: vehicule)
        }
    }
    
    func toDictionnary() -> [String : Any] {
        var dict: [String: Any] = [
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "firebase_id": firebaseId,
            "id": id,
            "stripe_id": stripeId
        ]

        if let vehicule = self.vehicule {
            dict["vehicule"] = vehicule.toDictionary()
        }

        if let accountId = self.accountId {
            dict["account_id"] = accountId
        }

        if let last4 = self.externalLast4Digits, let bankName = self.externalBankName {
            dict["bank_last_4_digits"] = last4
            dict["bank_name"] = bankName
        }

        return dict
    }
    
    static func logIn(email: String, password: String, complete: @escaping (Error?) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (customer, error) in
            if let error = error {
                complete(error)
            } else {
                AuthenticationHelper.updateAuthToken({ (error) in
                    if let error = error {
                        complete(error)
                    } else {
                        complete(nil)
                    }
                })
            }
        })
    }

    static func updateCustomerToken(_ token: String, complete: @escaping (Error?) -> Void) {
        APIClient.shared.updateCustomerDeviceToken(token: token, complete: complete)
    }
    
    static func getCustomer(complete: @escaping (Customer?, Error?) -> Void) {
        APIClient.shared.getCustomer(complete: complete)
    }
}

class NewCustomer {
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

    func register(complete: @escaping (Error?) -> Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (customer, error) in
            if let error = error {
                complete(error)
            } else if let customer = customer {
                self.firebaseId = customer.uid
                APIClient.shared.postCustomer(customer: self, complete: { (error) in
                    if let error = error {
                        try! FIRAuth.auth()!.signOut()
                        complete(error)
                    } else {
                        AuthenticationHelper.updateAuthToken({ (error) in
                            if let error = error {
                                complete(error)
                            } else {
                                complete(nil)
                            }
                        })
                    }
                })
            }
        })
    }
}
