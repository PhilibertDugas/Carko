//
//  AccountClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-15.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {
    func postAccount(account: Account, complete: @escaping (Error?) -> Void) {
        if let ip = AppState.getWiFiAddress() {
            let parameters: Parameters = ["account":[
                "legal_entity": account.toDictionary(),
                "tos_acceptance": [
                    "date": round(Date.init().timeIntervalSince1970),
                    "ip": ip
                ]
            ]]
            let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/accounts")
            request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).response { (response) in
                complete(response.error)
            }

        }
    }

    func postExternalAccount(token: String, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = ["external": ["token": token]]
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/external")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).response { (response) in
            complete(response.error)
        }
    }
}
