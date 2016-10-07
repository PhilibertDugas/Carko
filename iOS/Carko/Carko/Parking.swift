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
    var name: String
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.name = name
    }
    
    convenience init(parking: [String : Any]) {
        let latitude = parking["latitude"] as! CLLocationDegrees
        let longitude = parking["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: parking["photoURL"] as! String)!
        let name = parking["name"] as! String
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, name: name)
    }
    
    func persist() {
        let latitudekey = "\(latitude)".replacingOccurrences(of: ".", with: "-")
        let longitudeKey = "\(longitude)".replacingOccurrences(of: ".", with: "-")
        let newParking = ["\(latitudekey)_\(longitudeKey)": ["latitude": latitude, "longitude": longitude, "photoURL": "\(photoURL)", "name": name]] as [String : Any]
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
