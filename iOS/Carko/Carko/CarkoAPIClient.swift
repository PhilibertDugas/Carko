//
//  CarkoAPIClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Stripe

class CarkoAPIClient: NSObject, STPBackendAPIAdapter {
 
    static let sharedClient = CarkoAPIClient.init()
    let session: URLSession
    let baseUrlString = "https://5a7025d7.ngrok.io"
    
    
    override init() {
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
    
    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        let url = URL.init(string: baseUrlString)
        // TODO: Use the firebase ID here
        let path = "/customers/1"
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
        // TODO: Use the firebase ID here
        let path = "/customers/1/default_source"
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
        // TODO: Use the firebase ID here
        let path = "/customers/1/sources"
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
