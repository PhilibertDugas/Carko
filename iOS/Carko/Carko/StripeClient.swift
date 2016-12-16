//
//  StripeClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire
import Stripe

extension CarkoAPIClient: STPBackendAPIAdapter {
    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        let getUrl = baseUrl.appendingPathComponent("customers/\(self.customerId())")
        let parameters: Parameters = ["type": "stripe"]
        request(getUrl, parameters: parameters).response { (response) in
            let deserializer = STPCustomerDeserializer.init(data: response.data, urlResponse: response.response, error: response.error)
            if let error = deserializer.error {
                completion(nil, error)
                return
            } else if let customer = deserializer.customer {
                completion(customer, nil)
            }
        }
    }

    func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        let postUrl = baseUrl.appendingPathComponent("/customers/\(customerId())/default_source")
        let parameters: Parameters = ["customer": ["default_source": source.stripeID]]

        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            if let error = response.error {
                completion(error)
                return
            }
            completion(nil)
        }
    }

    func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        let postUrl = baseUrl.appendingPathComponent("/customers/\(self.customerId())/sources")
        let parameters: Parameters = ["customer": ["source": source.stripeID]]

        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            if let error = response.error {
                completion(error)
                return
            }
            completion(nil)
        }
    }

    func postCharge(charge: Charge, completion: @escaping (String?, Error?) -> Void) {
        let parameters: Parameters = ["charge": charge.toDictionary()]
        let postUrl = baseUrl.appendingPathComponent("/charges")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (data) in
            if let error = data.result.error {
                completion(nil, error)
            } else if let response = data.response, let value = data.result.value {
                if response.statusCode == 201 {
                    let dataDict = value as! NSDictionary
                    let id = dataDict["id"] as! String
                    completion(id, nil)
                } else {
                    completion(nil, NSError.init(domain: "Server Error", code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

    func createBankAccount(bankAccountParams: STPBankAccountParams) {
        let client = STPAPIClient.shared()
        client.createToken(withBankAccount: bankAccountParams) { (token, error) in
            print("\(token)")
        }
    }
}
