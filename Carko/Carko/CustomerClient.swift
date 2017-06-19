//
//  CustomerCLient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {
    func getCustomer(complete: @escaping(Customer?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("/customers/\(self.customerId())")
        request(url).responseJSON { (dataResponse) in
            if let error = dataResponse.result.error {
                complete(nil, error)
            } else if let response = dataResponse.response, let value = dataResponse.result.value {
                if response.statusCode == 200 {
                    if let customerDict = value as? [String: Any] {
                        let customer = Customer.init(customer: customerDict)
                        complete(customer, nil)
                    } else {
                        // In this case, the backend returned `null` because the customer does not exists
                        complete(nil, nil)
                    }
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete(nil, NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

    func postCustomer(customer: NewCustomer, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = ["customer": customer.toDictionary()]
        let postUrl = baseUrl.appendingPathComponent("/customers")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }

    func updateCustomerDeviceToken(token: String, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = ["customer": ["token": token]]
        let patchUrl = baseUrl.appendingPathComponent("/customers/\(AuthenticationHelper.getCustomer().id)")
        request(patchUrl, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).response { (reponse) in
            complete(reponse.error)
        }
    }
}
