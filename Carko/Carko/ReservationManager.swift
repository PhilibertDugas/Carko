//
//  ReservationManager.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-22.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

class ReservationManager: NSObject {
    static let shared = ReservationManager.init()
    private var reservations: [(Reservation?)]? = nil

    func cacheReservations(reservations: [(Reservation?)]) {
        self.reservations = reservations
        UserDefaults.standard.set(reservations.map { $0?.toDictionnary() }, forKey: "reservations")
    }

    func getReservations() -> [(Reservation?)] {
        if self.reservations == nil {
            self.reservations = []
            let array = UserDefaults.standard.array(forKey: "reservations")!
            for dict in array {
                self.reservations?.append(Reservation.init(reservation: dict as! [String : Any]))
            }
        }
        return self.reservations!
    }
}
