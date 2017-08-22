//
//  ParkingReservervationInfo.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-26.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation
import Crashlytics

struct Reservation {
    var id: Int
    var parking: Parking?
    var event: Event?
    var customerId: Int
    var isActive: Bool
    var startTime: String
    var stopTime: String
    var totalCost: Float
    var charge: String

    init(id: Int, parking: Parking?, event: Event?, customerId: Int, isActive: Bool, startTime: String, stopTime: String, totalCost: Float, charge: String) {
        self.id = id
        self.parking = parking
        self.event = event
        self.customerId = customerId
        self.isActive = isActive
        self.startTime = startTime
        self.stopTime = stopTime
        self.totalCost = totalCost
        self.charge = charge
    }

    init?(reservation: [String : Any]) {
        guard let id = reservation["id"] as? Int, let customerId = reservation["customer_id"] as? Int, let isActive = reservation["is_active"] as? Bool, let startTime = reservation["start_time"] as? String, let stopTime = reservation["stop_time"] as? String, let totalCost = reservation["total_cost"] as? Float, let charge = reservation["charge"] as? String, let event = reservation["event"] as? [String: Any], let parkingDict = reservation["parking"] as? [String: Any]
        else {
            Crashlytics.sharedInstance().recordError(NSError.init(domain: "Invalid data in Reservation init", code: 0, userInfo: nil), withAdditionalUserInfo: reservation)
            return nil
        }

        self.init(id: id, parking: Parking.init(parking: parkingDict), event: Event.init(event: event), customerId: customerId, isActive: isActive, startTime: startTime, stopTime: stopTime, totalCost: totalCost, charge: charge)
    }

    func toDictionnary() -> [String : Any] {
        var dict: [String: Any] = [
            "id": self.id,
            "customer_id": self.customerId,
            "is_active": self.isActive,
            "start_time": self.startTime,
            "stop_time": self.stopTime,
            "total_cost": self.totalCost,
            "charge": self.charge
        ]
        if let parking = self.parking {
            dict["parking"] = parking.toDictionary()
        }
        return dict
    }

    static func getCustomerReservations(_ completion: @escaping ([(Reservation?)], Error?) -> Void) {
        APIClient.shared.getCustomerReservations(complete: completion)
    }

    static func getCustomerActiveReservations(_ completion: @escaping ([(Reservation?)], Error?) -> Void) {
        APIClient.shared.getCustomerActiveReservations { (reservations, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else {
                ReservationManager.shared.cacheReservations(reservations: reservations)
            }
            completion(reservations, error)
        }
    }}

struct NewReservation {
    var parkingId: Int
    var customerId: Int
    var isActive: Bool
    var startTime: String
    var stopTime: String
    var totalCost: Float
    var charge: Charge

    init(parkingId: Int, customerId: Int, isActive: Bool, startTime: String, stopTime: String, totalCost: Float, charge: Charge) {
        self.parkingId = parkingId
        self.customerId = customerId
        self.isActive = isActive
        self.startTime = startTime
        self.stopTime = stopTime
        self.totalCost = totalCost
        self.charge = charge
    }

    init(reservation: [String : Any]) {
        let parkingId = reservation["parking_id"] as! Int
        let customerId = reservation["customer_id"] as! Int
        let eventId = reservation["event_id"] as! Int
        let isActive = reservation["is_active"] as! Bool
        let startTime = reservation["start_time"] as! String
        let stopTime = reservation["stop_time"] as! String
        let totalCost = reservation["total_cost"] as! Float
        let charge = Charge.init(charge: reservation["charge"] as! [String: Any])
        self.init(parkingId: parkingId, customerId: customerId, isActive: isActive, startTime: startTime, stopTime: stopTime, totalCost: totalCost, charge: charge)
    }

    func toDictionnary() -> [String : Any] {
        return [
            "parking_id": self.parkingId,
            "customer_id": self.customerId,
            "is_active": self.isActive,
            "start_time": self.startTime,
            "stop_time": self.stopTime,
            "total_cost": self.totalCost,
            "charge": self.charge.toDictionary()
        ]
    }

    func persist(complete: @escaping (Reservation?, Error?) -> Void) {
        APIClient.shared.createReservation(reservation: self, complete: complete)
    }
}
