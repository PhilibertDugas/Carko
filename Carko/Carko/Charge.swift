//
//  Charge.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class Charge: NSObject {
    var customer: String
    var amount: Int
    var currency: String
    var parkingId: Int

    init(customer: String, amount: Int, currency: String, parkingId: Int) {
        self.customer = customer
        self.amount = amount
        self.currency = currency
        self.parkingId = parkingId
    }

    func toDictionary() -> [String : Any] {
        return [
            "customer": customer,
            "amount": amount,
            "currency": currency,
            "parking_id": parkingId
        ]
    }

    func persist(completion: @escaping (String?, Error?) -> Void) {
        CarkoAPIClient.shared.postCharge(charge: self, completion: completion)
    }
}
