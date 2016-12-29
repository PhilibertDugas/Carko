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

extension APIClient: STPBackendAPIAdapter {
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

    func createBankAccount(bankAccountParams: STPBankAccountParams) {
        let client = STPAPIClient.shared()
        client.createToken(withBankAccount: bankAccountParams) { (token, error) in
            print("\(token)")
        }
    }
}
