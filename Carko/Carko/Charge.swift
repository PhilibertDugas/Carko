//
//  Charge.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

struct Charge {
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

    init(charge: [String: Any]) {
        let customer = charge["customer"] as! String
        let amount = charge["amount"] as! Int
        let currency = charge["currency"] as! String
        let parkingId = charge["parking_id"] as! Int
        self.init(customer: customer, amount: amount, currency: currency, parkingId: parkingId)
    }

    func toDictionary() -> [String : Any] {
        return [
            "customer": customer,
            "amount": amount,
            "currency": currency,
            "parking_id": parkingId
        ]
    }
}
