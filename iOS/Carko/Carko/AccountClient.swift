//
//  AccountClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension CarkoAPIClient {
    func postAccount(account: Account, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = ["account":[
            "legal_entity": account.toDictionary(),
            "tos_acceptance": [
                "date": 1481597793,
                "ip": "192.168.0.1"
            ]
        ]]
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id!)/accounts")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }
}
