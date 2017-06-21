//
//  APIClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth
import Alamofire

class APIClient: NSObject {
    static let shared = APIClient.init()
    // This is initialized in the AppDelegate depending of the build scheme (Development or Production)
    var baseUrl: URL!

    func customerId() -> String {
        return (Auth.auth().currentUser?.uid)!
    }

    func authHeaders() -> HTTPHeaders! {
        return ["Authorization": "Bearer \(AuthenticationHelper.getAuthToken())"]
    }
}
