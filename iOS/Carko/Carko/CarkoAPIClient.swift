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
    var baseUrl: URL!
    //let baseUrlString = "https://7e80847b.ngrok.io"

    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession.init(configuration: configuration)
        self.baseUrl = URL.init(string: baseUrlString)
    }

    func customerId() -> String {
        return (FIRAuth.auth()?.currentUser?.uid)!
    }

    func decodeResponse(_ response: URLResponse?, error: NSError?) -> NSError? {
        if let httpResponse = response as? HTTPURLResponse
            , httpResponse.statusCode != 200 {
            return error ?? NSError.networkingError(httpResponse.statusCode)
        }
        return error
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
        let postUrl = baseUrl.appendingPathComponent("/charges")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            if response.error != nil {
                completion(response.error)
            } else {
                completion(nil)
            }
        }
    }
}


// Parking API calls
extension CarkoAPIClient {
    func postParking(parking: Parking, complete: @escaping (Error?) -> Void ) -> Void {
        let parameters: Parameters = parking.toDictionary()
        let postUrl = baseUrl.appendingPathComponent("/parkings")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }

    func getAllParkings(complete: @escaping([(Parking)], Error?) -> Void) -> Void {
        let getUrl = baseUrl.appendingPathComponent("/parkings")
        request(getUrl).responseJSON { (response) in
            if let error = response.result.error {
                complete([], error)
            } else if let result = response.result.value {
                let parkingArray = result as! NSArray
                var parkings = [(Parking)]()
                for parking in parkingArray {
                    let dict = parking as! [String : Any]
                    parkings.append(Parking.init(parking: dict))
                }
                complete(parkings, nil)
            }
        }
    }

    func getCustomerParkings(complete: @escaping([(Parking)], Error?) -> Void) -> Void {
        let getUrl = baseUrl.appendingPathComponent("/customers/\(customerId())")
        let parameters: Parameters = ["type": "parkings"]
        request(getUrl, parameters: parameters).responseJSON { (response) in
            if let error = response.result.error {
                complete([], error)
            } else if let result = response.result.value {
                let parkingArray = result as! NSArray
                var parkings = [(Parking)]()
                for parking in parkingArray {
                    let dict = parking as! [String : Any]
                    parkings.append(Parking.init(parking: dict))
                }
                complete(parkings, nil)
            }
        }
    }
    
    func deleteParking(parking: Parking, complete: @escaping (Error?) -> Void) -> Void {
        let deleteUrl = baseUrl.appendingPathComponent("/parkings/\(parking.id!)")
        request(deleteUrl, method: .delete).response { (response) in
            if let error = response.error {
                complete(error)
            } else {
                complete(nil)
            }
        }
    }
}

extension CarkoAPIClient: STPBackendAPIAdapter {
    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        let url = URL.init(string: baseUrlString)
        let path = "/customers/\(customerId())?type=stripe"
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
        let postUrl = baseUrl.appendingPathComponent("/customers/\(customerId())/sources")
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
