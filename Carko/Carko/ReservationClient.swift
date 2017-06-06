//
//  ReservationClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-10.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {
    func createReservation(reservation: NewReservation, complete: @escaping (Reservation?, Error?) -> Void) {
        let parameters: Parameters = ["reservation": reservation.toDictionnary()]
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/reservations")
        request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (returned) in
            if let error = returned.result.error {
                complete(nil, error)
            } else if let response = returned.response, let value = returned.result.value {
                if response.statusCode == 201 {
                    let reservation = value as! [String: Any]
                    complete(Reservation.init(reservation: reservation), nil)
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete(nil, NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

    func getCustomerReservations(complete: @escaping ([(Reservation)], Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/reservations")
        request(url, method: .get, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (returned) in
            if let error = returned.result.error {
                complete([], error)
            } else if let response = returned.response, let value = returned.result.value {
                if response.statusCode == 200 {
                    let reservationArray = value as! NSArray
                    var reservations = [(Reservation)]()
                    for reservation in reservationArray {
                        let dict = reservation as! [String : Any]
                        reservations.append(Reservation.init(reservation: dict))
                    }
                    complete(reservations, nil)
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete([], NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

    func getCustomerActiveReservations(complete: @escaping ([(Reservation)], Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("/customers/\(AppState.shared.customer.id)/active_reservations")
        request(url, method: .get, encoding: JSONEncoding.default, headers: authHeaders()).responseJSON { (returned) in
            if let error = returned.result.error {
                complete([], error)
            } else if let response = returned.response, let value = returned.result.value {
                if response.statusCode == 200 {
                    let reservationArray = value as! NSArray
                    var reservations = [(Reservation)]()
                    for reservation in reservationArray {
                        let dict = reservation as! [String : Any]
                        reservations.append(Reservation.init(reservation: dict))
                    }
                    complete(reservations, nil)
                } else {
                    let error = value as! NSDictionary
                    let errorMessage = error.object(forKey: "error") as! String
                    complete([], NSError.init(domain: errorMessage, code: response.statusCode, userInfo: nil))
                }
            }
        }
    }

}
