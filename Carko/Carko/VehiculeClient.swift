//
//  VehiculeClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {
    func postVehicule(vehicule: Vehicule, complete: @escaping (Error?, Vehicule?) -> Void) {
        let parameters: Parameters = vehicule.toDictionary()
        let url = baseUrl.appendingPathComponent("/customers/\(AuthenticationHelper.getCustomer().id)/vehicules")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (data) in
            if let error = data.result.error {
                complete(error, nil)
            } else if let response = data.response, let value = data.result.value {
                if response.statusCode == 201 {
                    let dict = value as! [String: Any]
                    complete(nil, Vehicule.init(vehicule: dict))
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete(NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil), nil)
                }
            }
        }
    }
}
