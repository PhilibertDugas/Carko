//
//  ParkingReservervationInfo.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-11-26.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class Reservation: NSObject {
    var parkingId: Int
    var customerId: Int
    var isActive: Bool
    var startTime: String
    var stopTime: String
    var totalCost: Float

    init(parkingId: Int, customerId: Int, isActive: Bool, startTime: String, stopTime: String, totalCost: Float) {
        self.parkingId = parkingId
        self.customerId = customerId
        self.isActive = isActive
        self.startTime = startTime
        self.stopTime = stopTime
        self.totalCost = totalCost
        super.init()
    }

    convenience init(reservation: [String : Any]) {
        let parkingId = reservation["parking_id"] as! Int
        let customerId = reservation["customer_id"] as! Int
        let isActive = reservation["is_active"] as! Bool
        let startTime = reservation["start_time"] as! String
        let stopTime = reservation["stop_time"] as! String
        let totalCost = reservation["total_cost"] as! Float
        self.init(parkingId: parkingId, customerId: customerId, isActive: isActive, startTime: startTime, stopTime: stopTime, totalCost: totalCost)
    }

    func toDictionnary() -> [String : Any] {
        return [ "reservation": [
                "parking_id": self.parkingId,
                "customer_id": self.customerId,
                "is_active": self.isActive,
                "start_time": self.startTime,
                "stop_time": self.stopTime,
                "total_cost": self.totalCost
            ]
        ]
    }

    func persist(complete: @escaping (Error?) -> Void) {
        CarkoAPIClient.sharedClient.createReservation(reservation: self, complete: complete)
    }
}
