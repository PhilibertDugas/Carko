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
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL) {
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
    }
    
    convenience init(parking: [String : Any]) {
        let latitude = parking["latitude"] as! CLLocationDegrees
        let longitude = parking["longitude"] as! CLLocationDegrees
        let photoURL = URL.init(string: parking["photoURL"] as! String)!
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL)
    }
    
    func postParking() {
        let newParking = ["latitude": latitude, "longitude": longitude, "photoURL": "\(photoURL)"] as [String : Any]
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
