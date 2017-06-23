//
//  Event.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-19.
//  Copyright © 2017 QH4L. All rights reserved.
//

import CoreLocation
import UIKit

struct Event {
    var id: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL?
    var range: Int
    var price: Float
    var label: String
    var targetAudience: Int
    var startTime: String
    var endTime: String

    var stopTime: String {
        return endTime
    }

    // Convenience init, only for placeholder cells in the EventsCollectionView
    init() {
        self.init(id: 1, latitude: 1.0, longitude: 1.0, photoURL: nil, range: 10, price: 10.0, label: "Placeholder", targetAudience: 100, startTime: "2017-06-05T00:00:00Z", endTime: "2017-06-05T00:00:00Z")
    }

    init(id: Int, latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL?, range: Int, price: Float, label: String, targetAudience: Int, startTime: String, endTime: String) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.range = range
        self.price = price
        self.label = label
        self.targetAudience = targetAudience
        self.startTime = startTime
        self.endTime = endTime
    }

    init(event: [String: Any]) {
        let id = event["id"] as! Int
        let latitude = event["latitude"] as! CLLocationDegrees
        let longitude = event["longitude"] as! CLLocationDegrees
        var potentialPhotoUrl: URL? = nil
        if let url = event["photo_url"] as? String {
            potentialPhotoUrl = URL.init(string: url)
        }
        let range = event["range"] as! Int
        let price = event["price"] as! Float
        let label = event["label"] as! String
        let targetAudience = event["target_audience"] as! Int
        let startTime = event["start_time"] as! String
        let endTime = event["end_time"] as! String
        self.init(id: id, latitude: latitude, longitude: longitude, photoURL: potentialPhotoUrl, range: range, price: price, label: label, targetAudience: targetAudience, startTime: startTime, endTime: endTime)
    }

    func heightForLabel(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: self.label).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }

    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: self.latitude, longitude: self.longitude)
    }
}

extension Event {
    static func getAllEvents(_ complete: @escaping([(Event)], Error?) -> Void) {
        APIClient.shared.getAllEvents(complete: complete)
    }

    func getParkings(_ complete: @escaping([(Parking)], Error?) -> Void) {
        APIClient.shared.getEventParkings(self, complete: complete)
    }

    func toDictionary() -> [String : Any] {
        var dict: [String: Any] = [
            "id": self.id,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "range": self.range,
            "price": self.price,
            "label": self.label,
            "target_audience": self.targetAudience,
            "start_time": self.startTime,
            "end_time": self.endTime
        ]
        if let url = self.photoURL {
            dict["photo_url"] = url.absoluteString
        }
        return dict
    }
}
