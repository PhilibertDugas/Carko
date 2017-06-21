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
    var displayName: String
    var firebaseId: String
    var stripeId: String

    var vehicule: Vehicule?
    var accountId: String?
    var externalLast4Digits: String?
    var externalBankName: String?

    var firstName: String {
        return displayName.components(separatedBy: " ").first!
    }

    var lastName: String {
        return displayName.components(separatedBy: " ").last!
    }

    init(email: String, displayName: String, id: Int, firebaseId: String, stripeId: String) {
        self.email = email
        self.displayName = displayName
        self.id = id
        self.firebaseId = firebaseId
        self.stripeId = stripeId
    }

    init(customer: [String: Any]) {
        let email = customer["email"] as! String
        let displayName = customer["display_name"] as! String
        let id = customer["id"] as! Int
        let firebaseId = customer["firebase_id"] as! String
        let stripeId = customer["stripe_id"] as! String

        self.init(email: email, displayName: displayName, id: id, firebaseId: firebaseId, stripeId: stripeId)

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
            "display_name": displayName,
            "firebase_id": firebaseId,
            "id": id,
            "stripe_id": stripeId
        ]

        if let vehicule = self.vehicule {
            dict["vehicule_id"] = vehicule.id!
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

    func updateCustomer(_ complete: @escaping (Error?) -> Void) {
        APIClient.shared.updateCustomer(customer: self, complete: complete)
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
    var displayName: String
    var firebaseId: String

    init(email: String, displayName: String, firebaseId: String) {
        self.email = email
        self.displayName = displayName
        self.firebaseId = firebaseId
    }

    func toDictionary() -> [String : Any] {
        return [
            "email": email,
            "display_name": displayName,
            "firebase_id": firebaseId
        ]
    }

    func register(complete: @escaping (Error?) -> Void) {
        APIClient.shared.postCustomer(customer: self, complete: complete)
    }
}
