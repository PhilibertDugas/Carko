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
    func postVehicule(vehicule: Vehicule, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = vehicule.toDictionary()
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/vehicules")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (data) in
            if let error = data.result.error {
                complete(error)
            } else if let response = data.response, let value = data.result.value {
                if response.statusCode == 201 {
                    complete(nil)
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete(NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil))
                }
            }
        }
    }
}
