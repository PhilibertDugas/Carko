//
//  Parking.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import FirebaseAuth
import CoreLocation

class Parking: NSObject {
    var id: Int?
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
        let photoURL = URL.init(string: parking["photo_url"] as! String)!
        let address = parking["address"] as! String
        let price = Float(parking["price"] as! String)!
        let parkingDescription = parking["description"] as! String

        let availabilityInfo = ParkingAvailabilityInfo.init(availabilityInfo: parking["availability_info"] as! [String : Any])
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, price: price, parkingDescription: parkingDescription, availabilityInfo: availabilityInfo)

        if let identifier = parking["id"] as? Int {
            self.id = identifier
        }
    }
    
    func persist(complete: @escaping (Error?) -> Void) {
        CarkoAPIClient.sharedClient.postParking(parking: self, complete: complete)
    }

    func delete() {
        CarkoAPIClient.sharedClient.deleteParking(parking: self) { (error) in
            print(error.debugDescription)
        }
    }
    
    func toDictionary() -> [String : Any] {
        let customer_firebase_id = FIRAuth.auth()?.currentUser?.uid
        return ["parking":
            [
                "latitude": latitude,
                "longitude": longitude,
                "photo_url": "\(photoURL)",
                "address": address,
                "price": price,
                "description": parkingDescription,
                "customer_firebase_id": customer_firebase_id!,
                "availability_info": availabilityInfo.toDictionary()
            ]
        ] as [String : Any]
    }
    
    class func getAllParkings() {
        CarkoAPIClient.sharedClient.getAllParkings { (parkings, error) in
            if let error = error {
                print(error)
            } else {
                let data = ["data" : parkings]
                NotificationCenter.default.post(name: Notification.Name.init("ParkingFetched"), object: nil, userInfo: data)
            }
        }
    }

    class func getCustomerParkings() {
        CarkoAPIClient.sharedClient.getCustomerParkings { (parkings, error) in
            if let error = error {
                print(error)
            } else {
                let data = ["data" : parkings]
                NotificationCenter.default.post(name: Notification.Name.init("CustomerParkingFetched"), object: nil, userInfo: data)
            }
        }
    }
}
