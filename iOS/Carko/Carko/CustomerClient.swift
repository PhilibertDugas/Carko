//
//  CustomerCLient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension CarkoAPIClient {
    func getCustomer(complete: @escaping(Customer?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("/customers/\(customerId())")
        request(url).responseJSON { (response) in
            if let error = response.result.error {
                complete(nil, error)
            } else if let result = response.result.value {
                if let customerDict = result as? [String: Any] {
                    let customer = Customer.init(customer: customerDict)
                    complete(customer, nil)
                } else {
                    complete(nil, NSError.init(domain: "Error with server", code: 1, userInfo: nil))
                }
            }
        }
    }

    func postCustomer(customer: Customer, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = ["customer": customer.toDictionnary()]
        let postUrl = baseUrl.appendingPathComponent("/customers")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }
}
