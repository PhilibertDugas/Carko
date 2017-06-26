//
//  ParkingClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics

extension APIClient {
    func createParking(parking: Parking, complete: @escaping (Error?, Parking?) -> Void ) {
        let parameters: Parameters = ["parking": parking.toDictionary()]
        let postUrl = baseUrl.appendingPathComponent("/customers/\(AuthenticationHelper.getCustomer().id)/parkings")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (dataResponse) in
            if let error = dataResponse.result.error {
                complete(error, nil)
            } else if let response = dataResponse.response, let value = dataResponse.result.value {
                if response.statusCode == 201 {
                    let parking = value as! [String: Any]
                    complete(nil, Parking.init(parking: parking))
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete(NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil), nil)
                }
            }
        }
    }

    func updateParking(parking: Parking, complete: @escaping (Error?, Parking?) -> Void ) {
        let parameters: Parameters = ["parking": parking.toDictionary()]
        let patchUrl = baseUrl.appendingPathComponent("/customers/\(AuthenticationHelper.getCustomer().id)/parkings/\(parking.id!)")
        request(patchUrl, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (dataResponse) in
            if let error = dataResponse.result.error {
                complete(error, nil)
            } else if let response = dataResponse.response, let value = dataResponse.result.value {
                if response.statusCode == 200 {
                    let parking = value as! [String: Any]
                    complete(nil, Parking.init(parking: parking))
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete(NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil), nil)
                }
            }
        }
    }

    func getCustomerParkings(complete: @escaping([(Parking?)], Error?) -> Void) {
        let getUrl = baseUrl.appendingPathComponent("/customers/\(AuthenticationHelper.getCustomer().id)/parkings")
        request(getUrl, headers: authHeaders()).responseJSON { (returned) in
            if let error = returned.result.error {
                complete([], error)
            } else if let response = returned.response, let value = returned.result.value {
                if response.statusCode == 200 {
                    complete(self.returnParkings(value: value), nil)
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete([], NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

    func deleteParking(parking: Parking, complete: @escaping (Error?) -> Void) {
        parking.isDeleted = true
        self.updateParking(parking: parking) { (error, _) in
            complete(error)
        }
    }

    private func returnParkings(value: Any?) -> [(Parking?)] {
        guard let parkingArray = value as? NSArray else { return [] }
        var parkings: [(Parking?)] = []
        for parking in parkingArray {
            guard let dict = parking as? [String : Any] else {
                Crashlytics.sharedInstance().recordError(NSError.init(domain: "Received bad parking data data", code: 0, userInfo: nil))
                continue
            }
            parkings.append(Parking.init(parking: dict))
        }
        return parkings
    }
}
