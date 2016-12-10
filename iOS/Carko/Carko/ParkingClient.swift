//
//  ParkingClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

// Parking API calls
extension CarkoAPIClient {
    func createParking(parking: Parking, complete: @escaping (Error?) -> Void ) {
        let parameters: Parameters = ["parking": parking.toDictionary()]
        let postUrl = baseUrl.appendingPathComponent("/parkings")
        request(postUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }

    func getAllParkings(complete: @escaping([(Parking)], Error?) -> Void) {
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

    func getCustomerParkings(complete: @escaping([(Parking)], Error?) -> Void) {
        let getUrl = baseUrl.appendingPathComponent("/customers/\(self.customerId())")
        let parameters: Parameters = ["type": "parkings"]
        request(getUrl, parameters: parameters).responseJSON { (returned) in
            if let error = returned.result.error {
                complete([], error)
            } else if let response = returned.response, let value = returned.result.value {
                if response.statusCode == 200 {
                    let parkingArray = value as! NSArray
                    var parkings = [(Parking)]()
                    for parking in parkingArray {
                        let dict = parking as! [String : Any]
                        parkings.append(Parking.init(parking: dict))
                    }
                    complete(parkings, nil)

                } else {
                    complete([], NSError.init(domain: "HTTP Error", code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

    func deleteParking(parking: Parking, complete: @escaping (Error?) -> Void) {
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
