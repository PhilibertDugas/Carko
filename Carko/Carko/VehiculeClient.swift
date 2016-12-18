//
//  VehiculeClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension CarkoAPIClient {
    func postVehicule(vehicule: Vehicule, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = vehicule.toDictionary()
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/vehicules")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }
}
