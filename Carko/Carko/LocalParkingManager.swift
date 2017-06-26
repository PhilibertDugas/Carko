//
//  LocalParkingManager.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-26.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import Crashlytics

class LocalParkingManager: NSObject {
    static let shared = LocalParkingManager.init()
    private var customerParkings: [(Parking)] = []

    func setParkings(_ parkings: [(Parking)]) {
        self.customerParkings = parkings
    }

    func getParkings() -> [(Parking)] {
        return self.customerParkings
    }

    func insertParking(_ parking: Parking) {
        self.customerParkings.append(parking)
    }

    func updateParking(_ parking: Parking) {
        guard let updatedId = parking.id else { return }
        var updateIndex: Int? = nil
        for (index, p) in self.customerParkings.enumerated() {
            guard let id = p.id else { continue }
            if id == updatedId {
                updateIndex = index
            }
        }
        guard let index = updateIndex else { return }
        self.customerParkings[index] = parking
    }

    func removeParking(_ parking: Parking) {
        guard let deletedId = parking.id else { return }
        var deletionIndex: Int? = nil
        for (index, p) in self.customerParkings.enumerated() {
            guard let id = p.id else { continue }
            if id == deletedId {
                deletionIndex = index
            }
        }
        guard let index = deletionIndex else { return }
        self.customerParkings.remove(at: index)
    }
}
