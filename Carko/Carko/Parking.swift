//
//  Parking.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import CoreLocation

class Parking {
    var id: Int?
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL?
    var address: String
    var price: Float
    var pDescription: String
    var isAvailable: Bool
    var isComplete: Bool
    var customerId: Int
    var multiplePhotoUrls: [(URL)]

    var availabilityInfo: AvailabilityInfo

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL?, address: String, price: Float, pDescription: String, isAvailable: Bool, isComplete: Bool, availabilityInfo: AvailabilityInfo, customerId: Int, multiplePhotoUrls: [(URL)]) {
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.address = address
        self.price = price
        self.pDescription = pDescription
        self.isAvailable = isAvailable
        self.availabilityInfo = availabilityInfo
        self.customerId = customerId
        self.isComplete = isComplete
        self.multiplePhotoUrls = multiplePhotoUrls
    }

    convenience init() {
        self.init(latitude: CLLocationDegrees.init(75), longitude: CLLocationDegrees.init(-135), photoURL: URL.init(string: ""),address: "Select a location", price: 1.0, pDescription: "", isAvailable: true, isComplete: false, availabilityInfo: AvailabilityInfo.init(), customerId: AuthenticationHelper.getCustomer().id, multiplePhotoUrls: [])
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
        let isComplete = parking["is_complete"] as! Bool

        let availabilityInfo = AvailabilityInfo.init(availabilityInfo: parking["availability_info"] as! [String : Any])
        let multiplePhotoString = parking["multiple_photo_urls"] as! [(String)]
        var multipleUrls: [(URL)] = []
        for element in multiplePhotoString {
            multipleUrls.append(URL.init(string: element.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, price: price, pDescription: pDescription, isAvailable: isAvailable, isComplete: isComplete, availabilityInfo: availabilityInfo, customerId: customerId, multiplePhotoUrls: multipleUrls)

        if let identifier = parking["id"] as? Int {
            self.id = identifier
        }
    }

    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: self.latitude, longitude: self.longitude)
    }
}

extension Parking {
    func persist(complete: @escaping (Error?) -> Void) {
        APIClient.shared.createParking(parking: self) { (error, parking) in
            if let parking = parking {
                AppState.shared.customerParkings[parking.id!] = parking
            }
            complete(error)
        }
    }

    func update(complete: @escaping (Error?) -> Void) {
        APIClient.shared.updateParking(parking: self) { (error, parking) in
            if let parking = parking {
                AppState.shared.customerParkings[parking.id!] = parking
            }
            complete(error)
        }
    }

    func delete(complete: @escaping (Error?) -> Void) {
        APIClient.shared.deleteParking(parking: self) { (error) in
            if error == nil {
                AppState.shared.customerParkings.removeValue(forKey: self.id!)
            }
            complete(error)
        }
    }

    class func getAllParkings(_ complete: @escaping([(Parking)], Error?) -> Void) {
        APIClient.shared.getAllParkings(complete: complete)
    }

    class func getCustomerParkings(_ complete: @escaping([(Parking)], Error?) -> Void) {
        APIClient.shared.getCustomerParkings { (parkings, error) in
            complete(parkings, error)
        }
    }

    func toDictionary() -> [String : Any] {
        return [
            "latitude": latitude,
            "longitude": longitude,
            "photo_url": "\(photoURL!)",
            "address": address,
            "price": String.init(format: "%.2f", price),
            "description": pDescription,
            "is_available": isAvailable,
            "is_complete": isComplete,
            "availability_info": availabilityInfo.toDictionary(),
            "multiple_photo_urls": "\(multiplePhotoUrls)"
        ]
    }
}

class AvailabilityInfo: NSObject {
    var startTime: String
    var stopTime: String
    var alwaysAvailable: Bool

    // Array of 7 elements. Index 0 represents Monday up to index 6 which represents Sunday
    // 0 is true, 1 is false
    var daysAvailable: [(Bool)]

    init(alwaysAvailable: Bool, startTime: String, stopTime: String, daysAvailable: [(Bool)]) {
        self.alwaysAvailable = alwaysAvailable
        self.startTime = startTime
        self.stopTime = stopTime
        self.daysAvailable = daysAvailable
    }

    convenience init(availabilityInfo: [String : Any]) {
        let startTime = availabilityInfo["start_time"] as! String
        let stopTime = availabilityInfo["stop_time"] as! String
        let days = availabilityInfo["days_available"] as! [(Int)]
        var daysAvailable: [(Bool)] = []
        for day in days {
            let available = day == 0 ? true : false
            daysAvailable.append(available)
        }
        let alwaysAvailable = availabilityInfo["always_available"] as! Bool

        self.init(alwaysAvailable: alwaysAvailable, startTime: startTime, stopTime: stopTime, daysAvailable: daysAvailable)
    }

    convenience override init() {
        let startTime = "09:00"
        let stopTime = "17:00"
        let daysAvailable = [false, false, false, false, false, false, false]
        let alwaysAvailable = false
        self.init(alwaysAvailable: alwaysAvailable, startTime: startTime, stopTime: stopTime, daysAvailable: daysAvailable)
    }

    func toDictionary() -> [String : Any] {
        return [
            "always_available": alwaysAvailable,
            "start_time": startTime,
            "stop_time": stopTime,
            "days_available": daysIntegerFormat()
        ]
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let info = object as? AvailabilityInfo else { return false }
        return (info.startTime == self.startTime &&
        info.stopTime == self.stopTime &&
        info.alwaysAvailable == self.alwaysAvailable)
    }

    private func daysIntegerFormat() -> [(Int)] {
        var daysIntegerFormat = [(Int)]()
        let maxArrayIndex = daysAvailable.count - 1
        for i in 0...maxArrayIndex {
            daysIntegerFormat.append(daysAvailable[i] == true ? 0 : 1)
        }
        return daysIntegerFormat
    }

    class func formatter() -> DateFormatter {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter
    }

    func daysEnumerationText() -> String {
        var enumerationText = ""
        var needsPunctuation = false

        if self.alwaysAvailable || everyDayAvailable() {
            return "Everyday"
        }

        if daysAvailable[0] {
            enumerationText += "Mon"
            needsPunctuation = true
        }

        if daysAvailable[1] {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Tue"
            needsPunctuation = true
        }

        if daysAvailable[2] {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Wed"
            needsPunctuation = true
        }

        if daysAvailable[3] {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Thr"
            needsPunctuation = true
        }

        if daysAvailable[4] {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Fri"
            needsPunctuation = true
        }

        if daysAvailable[5] {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Sat"
            needsPunctuation = true
        }

        if daysAvailable[6] {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Sun"
            needsPunctuation = true
        }

        return enumerationText
    }

    private func everyDayAvailable() -> Bool {
        for day in daysAvailable {
            if !day {
                return false
            }
        }
        return true
    }
}

