//
//  CarkoAPIClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import FirebaseAuth

class CarkoAPIClient: NSObject {
 
    static let sharedClient = CarkoAPIClient.init()
    let session: URLSession
    let baseUrlString = "https://fast-crag-37122.herokuapp.com"
    //let baseUrlString = "https://784282f5.ngrok.io"
    let customerId: String

    override init() {
        customerId = (FIRAuth.auth()?.currentUser?.uid)!
        //customerId = "1"
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession.init(configuration: configuration)
    }

    func decodeResponse(_ response: URLResponse?, error: NSError?) -> NSError? {
        if let httpResponse = response as? HTTPURLResponse
            , httpResponse.statusCode != 200 {
            return error ?? NSError.networkingError(httpResponse.statusCode)
        }
        return error
    }

    func postParking(parking: Parking, complete: @escaping (Error?) -> Void ) -> Void {
        let parameters: Parameters = ["parking":
            ["latitude": parking.latitude, "longitude": parking.longitude, "address": parking.address, "customer_id": customerId]
        ]
        // let parameters: Parameters = parking.toDictionary()
        let baseUrl = URL.init(string: baseUrlString)
        let postUrl = baseUrl!.appendingPathComponent("/parkings")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }

    func postUser(user: User, complete: @escaping (Error?) -> Void) -> Void {
        let parameters: Parameters = user.toDictionnary()
        let baseUrl = URL.init(string: baseUrlString)
        let postUrl = baseUrl!.appendingPathComponent("/customers")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }

    func postCharge(_ source: STPSource, paymentContext: STPPaymentContext, completion: @escaping STPErrorBlock) {
        let parameters: Parameters = ["charge":
            [
                "source": source.stripeID,
                "amount": paymentContext.paymentAmount,
                "currency": paymentContext.paymentCurrency
            ]
        ]
        let baseUrl = URL.init(string: baseUrlString)
        let postUrl = baseUrl!.appendingPathComponent("/charges")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            if response.error != nil {
                completion(response.error)
            } else {
                completion(nil)
            }
        }
    }
}

extension CarkoAPIClient: STPBackendAPIAdapter {
    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        let url = URL.init(string: baseUrlString)
        let path = "/customers/\(customerId)"
        let customerUrl = url?.appendingPathComponent(path)
        var request = URLRequest.init(url: customerUrl!)
        request.httpMethod = "GET"
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let deserializer = STPCustomerDeserializer.init(data: data, urlResponse: urlResponse, error: error)
                if let error = deserializer.error {
                    completion(nil, error)
                    return
                } else if let customer = deserializer.customer {
                    completion(customer, nil)
                }
            }
        }
        task.resume()
    }

    func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        let baseUrl = URL.init(string: baseUrlString)
        let postUrl = baseUrl!.appendingPathComponent("/customers/\(customerId)/default_source")
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
        let baseUrl = URL.init(string: baseUrlString)
        let postUrl = baseUrl!.appendingPathComponent("/customers/\(customerId)/sources")
        let parameters: Parameters = ["customer": ["source": source.stripeID]]

        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            if let error = response.error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}

public extension NSError {
    public static func networkingError(_ status: Int) -> NSError {
        return NSError(domain: "FailingStatusCode", code: status, userInfo: nil)
    }
}
