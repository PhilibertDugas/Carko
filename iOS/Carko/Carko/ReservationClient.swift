//
//  ReservationClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension CarkoAPIClient {
    func createReservation(reservation: Reservation, complete: @escaping (Error?) -> Void) {
        let parameters: Parameters = ["reservation": reservation.toDictionnary()]
        let url = baseUrl.appendingPathComponent("/reservations")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { (response) in
            complete(response.error)
        }
    }
}
