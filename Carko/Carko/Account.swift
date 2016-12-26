//
//  Account.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class Account {
    var firstName: String
    var lastName: String
    let type = "individual"
    // FIXME: Handle this server side
    let personalIdNumber = "123456789"

    var address: AccountAddress
    var dob: AccountDateOfBirth

    init(firstName: String, lastName: String, address: AccountAddress, dob: AccountDateOfBirth) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.dob = dob
    }

    func toDictionary() -> [String: Any] {
        return [
            "first_name": firstName,
            "last_name": lastName,
            "type": type,
            "personal_id_number": personalIdNumber,
            "address": address.toDictionary(),
            "dob": dob.toDictionary()
        ]
    }

    func persist(completion: @escaping (Error?) -> Void) {
        CarkoAPIClient.shared.postAccount(account: self, complete: completion)
    }

    class func associateExternalAccount(token: String, completion: @escaping (Error?) -> Void) {
        CarkoAPIClient.shared.postExternalAccount(token: token, complete: completion)
    }

}

class AccountAddress {
    var city: String
    var line1: String
    var postalCode: String
    var state: String

    init(city: String, line1: String, postalCode: String, state: String) {
        self.city = city
        self.line1 = line1
        self.postalCode = postalCode
        self.state = state
    }

    func toDictionary() -> [String : Any] {
        return [
            "city": city,
            "line1": line1,
            "postal_code": postalCode,
            "state": state
        ]
    }
}

class AccountDateOfBirth {
    var day: String
    var month: String
    var year: String

    init(day: String, month: String, year: String) {
        self.day = day
        self.month = month
        self.year = year
    }

    func toDictionary() -> [String : Any] {
        return [
            "day": day,
            "month": month,
            "year": year
        ]
    }
}
