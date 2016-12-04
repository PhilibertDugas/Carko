//
//  Parking.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import CoreLocation

class Parking: NSObject {
    var id: Int?
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL?
    var address: String
    var price: Float
    var pDescription: String
    var isAvailable: Bool
    var customerId: Int

    var availabilityInfo: AvailabilityInfo

    var reservation: [(Reservation)]?

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL?, address: String, price: Float, pDescription: String, isAvailable: Bool, availabilityInfo: AvailabilityInfo, customerId: Int) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        
        self.address = address
        self.price = price
        self.pDescription = pDescription

        self.isAvailable = isAvailable
        self.availabilityInfo = availabilityInfo

        self.customerId = customerId
    }
    
    convenience init(parking: [String : Any]) {
        let latitude = parking["latitude"] as! CLLocationDegrees
        let longitude = parking["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: parking["photo_url"] as! String)
        let address = parking["address"] as! String
        let price = Float(parking["price"] as! String)!
        let pDescription = parking["description"] as! String
        let isAvailable = parking["is_available"] as! Bool
        let customerId = parking["customer_id"] as! Int

        let availabilityInfo = AvailabilityInfo.init(availabilityInfo: parking["availability_info"] as! [String : Any])
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, price: price, pDescription: pDescription, isAvailable: isAvailable, availabilityInfo: availabilityInfo, customerId: customerId)

        if let identifier = parking["id"] as? Int {
            self.id = identifier
        }
    }
    
    func persist(complete: @escaping (Error?) -> Void) {
        CarkoAPIClient.sharedClient.createParking(parking: self, complete: complete)
    }

    func delete() {
        CarkoAPIClient.sharedClient.deleteParking(parking: self) { (error) in
            print(error.debugDescription)
        }
    }
    
    func toDictionary() -> [String : Any] {
        return ["parking":
            [
                "latitude": latitude,
                "longitude": longitude,
                "photo_url": "\(photoURL!)",
                "address": address,
                "price": String.init(format: "%.2f", price),
                "description": pDescription,
                "customer_id": customerId,
                "is_available": isAvailable,
                "availability_info": availabilityInfo.toDictionary()
            ]
        ] as [String : Any]
    }


    func stopDate() -> Date {
        let todayFormater = DateFormatter.init()
        todayFormater.dateFormat = "d.M.yyyy"
        todayFormater.timeZone = NSTimeZone.local
        let todayString = todayFormater.string(from: Date.init())

        let convertString = "\(todayString) \(self.availabilityInfo.stopTime)"

        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "d.M.yyyy HH:mm"
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.date(from: convertString)!
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
