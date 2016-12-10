//
//  CarkoAPIClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-17.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import FirebaseAuth

class CarkoAPIClient: NSObject {
    static let shared = CarkoAPIClient.init()
    //let baseUrlString = "https://fast-crag-37122.herokuapp.com"
    let baseUrlString = "https://1e1de889.ngrok.io"
    var baseUrl: URL!

    override init() {
        self.baseUrl = URL.init(string: baseUrlString)
    }

    func customerId() -> String {
        return (FIRAuth.auth()?.currentUser?.uid)!
    }
}
