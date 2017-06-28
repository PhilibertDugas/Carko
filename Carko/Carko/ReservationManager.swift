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
    private var reservations: [(Reservation?)] = []

    func cacheReservations(reservations: [(Reservation?)]) {
        self.reservations = reservations
    }

    func getReservations() -> [(Reservation?)] {
        return self.reservations
    }
}
