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
    var startTime: String   // TODO : if possible change for non-String var
    var stopTime: String    // TODO : if possible change for non-String var
    var price: Float
    var parkingDescription: String
    
    var isMonday: Bool
    var isTuesday: Bool
    var isWednesday: Bool
    var isThursday: Bool
    var isFriday: Bool
    var isSaturday: Bool
    var isSunday: Bool
    
    var alwaysAvailable: Bool
    
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL, address: String, startTime: String, stopTime: String, price: Float, parkingDescription: String, isMonday: Bool, isTuesday: Bool, isWednesday: Bool, isThursday: Bool, isFriday: Bool, isSaturday: Bool, isSunday: Bool, alwaysAvailable: Bool) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        
        self.address = address
        self.startTime = startTime
        self.stopTime = stopTime
        self.price = price
        self.parkingDescription = parkingDescription
        
        self.isMonday = isMonday
        self.isTuesday = isTuesday
        self.isWednesday = isWednesday
        self.isThursday = isThursday
        self.isFriday = isFriday
        self.isSaturday = isSaturday
        self.isSunday = isSunday
        
        self.alwaysAvailable = alwaysAvailable
    }
    
    convenience init(parking: [String : Any]) {
        let latitude = parking["latitude"] as! CLLocationDegrees
        let longitude = parking["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: parking["photoURL"] as! String)!
        let address = parking["address"] as! String
        let startTime = parking["startTime"] as! String
        let stopTime = parking["stopTime"] as! String
        let price = parking["price"] as! Float
        let parkingDescription = parking["parkingDescription"] as! String
        let isMonday = parking["isMonday"] as! Bool
        let isTuesday = parking["isTuesday"] as! Bool
        let isWednesday = parking["isWednesday"] as! Bool
        let isThursday = parking["isThursday"] as! Bool
        let isFriday = parking["isFriday"] as! Bool
        let isSaturday = parking["isSaturday"] as! Bool
        let isSunday = parking["isSunday"] as! Bool
        let alwaysAvailable = parking["alwaysAvailable"] as! Bool
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, startTime: startTime, stopTime: stopTime, price: price, parkingDescription: parkingDescription, isMonday: isMonday, isTuesday: isTuesday, isWednesday: isWednesday, isThursday: isThursday, isFriday: isFriday, isSaturday: isSaturday, isSunday: isSunday, alwaysAvailable: alwaysAvailable)
    }
    
    func persist() {
        let latitudekey = "\(latitude)".replacingOccurrences(of: ".", with: "-")
        let longitudeKey = "\(longitude)".replacingOccurrences(of: ".", with: "-")
        let newParking = ["\(latitudekey)_\(longitudeKey)": ["latitude": latitude, "longitude": longitude, "photoURL": "\(photoURL)", "address": address, "startTime": startTime, "stopTime": stopTime, "price": price, "parkingDescription": parkingDescription, "isMonday": isMonday, "isTuesday": isTuesday, "isWednesday": isWednesday, "isThursday": isThursday, "isFriday": isFriday, "isSaturday": isSaturday, "isSunday": isSunday, "alwaysAvailable": alwaysAvailable]] as [String : Any]
        Parking.ref.child("parkings").updateChildValues(newParking)
    }
    
    func lapsOfTimeText() -> String
    {
        if self.startTime == "0:00 AM" && self.startTime == "12:00 PM"
        {
            return "All Day"
        }
        else
        {
            return (self.startTime + "-" + self.stopTime)
        }
    }
    
    func daysEnumerationText() -> String{
        var enumerationText = ""
        var needsPunctuation = false
        
        if isMonday && isTuesday && isWednesday && isThursday && isFriday && isSaturday && isSunday
        {
            return "Everyday"
        }
        
        if isMonday
        {
            enumerationText += "Mon"
            needsPunctuation = true
        }
        
        if isTuesday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Tue"
            needsPunctuation = true
        }
        
        if isWednesday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Wed"
            needsPunctuation = true
        }
        
        if isThursday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Thr"
            needsPunctuation = true
        }
        
        if isFriday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Fri"
            needsPunctuation = true
        }
        
        if isSaturday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Sat"
            needsPunctuation = true
        }
        
        if isSunday
        {
            if needsPunctuation
            {
                enumerationText += ", "
            }
            enumerationText += "Sun"
            needsPunctuation = true
        }
        
        return enumerationText
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
