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
        let url = URL.init(string: baseUrlString)
        let path = "/customers/\(customerId)/default_source"
        let defaultSourceUrl = url?.appendingPathComponent(path)
        let postString = "source=\(source.stripeID)"
        var request = URLRequest.init(url: defaultSourceUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }

    func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        let url = URL.init(string: baseUrlString)
        let path = "/customers/\(customerId)/sources"
        let sourceUrl = url?.appendingPathComponent(path)
        let postString = "source=\(source.stripeID)"
        var request = URLRequest.init(url: sourceUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
}

public extension NSError {
    public static func networkingError(_ status: Int) -> NSError {
        return NSError(domain: "FailingStatusCode", code: status, userInfo: nil)
    }
}
