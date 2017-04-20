//
//  Event.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-19.
//  Copyright © 2017 QH4L. All rights reserved.
//

import CoreLocation

struct Event {
    var id: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL?
    var range: Int
    var price: Float
    var label: String
    var targetAudience: Int

    init(id: Int, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL?, range: Int, price: Float, label: String, targetAudience: Int) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.range = range
        self.price = price
        self.label = label
        self.targetAudience = targetAudience
    }

    init(event: [String: Any]) {
        let id = event["id"] as! Int
        let latitude = event["latitude"] as! CLLocationDegrees
        let longitude = event["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: event["photo_url"] as! String)
        let range = event["range"] as! Int
        let price = event["price"] as! Float
        let label = event["label"] as! String
        let targetAudience = event["target_audience"] as! Int
        self.init(id: id, latitude: latitude, longitude: longitude, photoURL: photoURL, range: range, price: price, label: label, targetAudience: targetAudience)
    }
}

extension Event {
    func toDictionary() -> [String : Any] {
        return [
            "id": self.id,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "photo_url": (self.photoURL?.absoluteString)!,
            "range": self.range,
            "price": self.price,
            "label": self.label,
            "target_audience": self.targetAudience
        ]
    }
}
