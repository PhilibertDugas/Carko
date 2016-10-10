//
//  Parking.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import FirebaseDatabase
import CoreLocation

class Parking: NSObject {
    static let ref = FIRDatabase.database().reference()
    static let notificationCenter = NotificationCenter.default

    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL
    var address: String
    var startTime: String
    var stopTime: String
    var price: Float
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL, address: String, startTime: String, stopTime: String, price: Float) {
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.address = address
        self.startTime = startTime
        self.stopTime = stopTime
        self.price = price
    }
    
    convenience init(parking: [String : Any]) {
        let latitude = parking["latitude"] as! CLLocationDegrees
        let longitude = parking["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: parking["photoURL"] as! String)!
        let address = parking["address"] as! String
        let startTime = parking["startTime"] as! String
        let stopTime = parking["stopTime"] as! String
        let price = parking["price"] as! Float
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, startTime: startTime, stopTime: stopTime, price: price)
    }
    
    func persist() {
        let latitudekey = "\(latitude)".replacingOccurrences(of: ".", with: "-")
        let longitudeKey = "\(longitude)".replacingOccurrences(of: ".", with: "-")
        let newParking = ["\(latitudekey)_\(longitudeKey)": ["latitude": latitude, "longitude": longitude, "photoURL": "\(photoURL)", "address": address, "startTime": startTime, "stopTime": stopTime, "price": price]] as [String : Any]
        Parking.ref.child("parkings").updateChildValues(newParking)
    }
    
    class func getAllParkings() {
        ref.child("parkings").observeSingleEvent(of: .value, with: { (snapshot) in
            let parkings = snapshot.value! as? [String : Any]
            notificationCenter.post(name: Notification.Name.init("parkingFetched"), object: nil, userInfo: parkings)
        }) { (error) in
            print(error)
        }
    }
}
