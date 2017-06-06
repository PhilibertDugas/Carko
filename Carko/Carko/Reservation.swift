//
//  ParkingReservervationInfo.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-26.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

struct Reservation {
    var label: String
    var parkingId: Int
    var customerId: Int
    var isActive: Bool
    var startTime: String
    var stopTime: String
    var totalCost: Float
    var charge: String

    init(label: String, parkingId: Int, customerId: Int, isActive: Bool, startTime: String, stopTime: String, totalCost: Float, charge: String) {
        self.label = label
        self.parkingId = parkingId
        self.customerId = customerId
        self.isActive = isActive
        self.startTime = startTime
        self.stopTime = stopTime
        self.totalCost = totalCost
        self.charge = charge
    }

    init(reservation: [String : Any]) {
        let label = reservation["label"] as! String
        let parkingId = reservation["parking_id"] as! Int
        let customerId = reservation["customer_id"] as! Int
        let isActive = reservation["is_active"] as! Bool
        let startTime = reservation["start_time"] as! String
        let stopTime = reservation["stop_time"] as! String
        let totalCost = reservation["total_cost"] as! Float
        let charge = reservation["charge"] as! String
        self.init(label: label, parkingId: parkingId, customerId: customerId, isActive: isActive, startTime: startTime, stopTime: stopTime, totalCost: totalCost, charge: charge)
    }

    func toDictionnary() -> [String : Any] {
        return [
            "label": self.label,
            "parking_id": self.parkingId,
            "customer_id": self.customerId,
            "is_active": self.isActive,
            "start_time": self.startTime,
            "stop_time": self.stopTime,
            "total_cost": self.totalCost,
            "charge": self.charge
        ]
    }

    static func getCustomerReservations(_ completion: @escaping ([(Reservation)], Error?) -> Void) {
        APIClient.shared.getCustomerReservations(complete: completion)
    }

    static func getCustomerActiveReservations(_ completion: @escaping ([(Reservation)], Error?) -> Void) {
        APIClient.shared.getCustomerActiveReservations(complete: completion)
    }}

struct NewReservation {
    var label: String
    var parkingId: Int
    var customerId: Int
    var isActive: Bool
    var startTime: String
    var stopTime: String
    var totalCost: Float
    var charge: Charge

    init(label: String, parkingId: Int, customerId: Int, isActive: Bool, startTime: String, stopTime: String, totalCost: Float, charge: Charge) {
        self.label = label
        self.parkingId = parkingId
        self.customerId = customerId
        self.isActive = isActive
        self.startTime = startTime
        self.stopTime = stopTime
        self.totalCost = totalCost
        self.charge = charge
    }

    init(reservation: [String : Any]) {
        let label = reservation["label"] as! String
        let parkingId = reservation["parking_id"] as! Int
        let customerId = reservation["customer_id"] as! Int
        let isActive = reservation["is_active"] as! Bool
        let startTime = reservation["start_time"] as! String
        let stopTime = reservation["stop_time"] as! String
        let totalCost = reservation["total_cost"] as! Float
        let charge = Charge.init(charge: reservation["charge"] as! [String: Any])
        self.init(label: label, parkingId: parkingId, customerId: customerId, isActive: isActive, startTime: startTime, stopTime: stopTime, totalCost: totalCost, charge: charge)
    }

    func toDictionnary() -> [String : Any] {
        return [
            "label": self.label,
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
