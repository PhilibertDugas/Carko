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
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL
    
    var address: String
    var price: Float
    var parkingDescription: String
    var availabilityInfo: ParkingAvailabilityInfo
    
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL, address: String, price: Float, parkingDescription: String, availabilityInfo: ParkingAvailabilityInfo) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        
        self.address = address
        self.price = price
        self.parkingDescription = parkingDescription
        self.availabilityInfo = availabilityInfo
    }
    
    convenience init(parking: [String : Any]) {
        let latitude = parking["latitude"] as! CLLocationDegrees
        let longitude = parking["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: parking["photoURL"] as! String)!
        let address = parking["address"] as! String
        let price = parking["price"] as! Float
        let parkingDescription = parking["parkingDescription"] as! String

        let availabilityInfo = ParkingAvailabilityInfo.init(availabilityInfo: parking["availabilityInfo"] as! [String : Any])
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, price: price, parkingDescription: parkingDescription, availabilityInfo: availabilityInfo)
    }
    
    func persist() {
        Parking.ref.child("parkings").updateChildValues(self.toDictionary())
        //CarkoAPIClient.sharedClient.postParking(parking: self) { (error) in
        //    print(error.debugDescription)
        //}
    }
    
    func toDictionary() -> [String : Any] {
        let latitudekey = "\(latitude)".replacingOccurrences(of: ".", with: "-")
        let longitudeKey = "\(longitude)".replacingOccurrences(of: ".", with: "-")
        return ["\(latitudekey)_\(longitudeKey)":
            [
                "latitude": latitude,
                "longitude": longitude,
                "photoURL": "\(photoURL)",
                "address": address,
                "price": price,
                "parkingDescription": parkingDescription,
                "availabilityInfo": availabilityInfo.toDictionary()
            ]
        ] as [String : Any]
    }
    
    class func getAllParkings() {
        ref.child("parkings").observeSingleEvent(of: .value, with: { (snapshot) in
            let parkings = snapshot.value! as? [String : Any]
            NotificationCenter.default.post(name: Notification.Name.init("parkingFetched"), object: nil, userInfo: parkings)
        }) { (error) in
            print(error)
        }
    }
}
