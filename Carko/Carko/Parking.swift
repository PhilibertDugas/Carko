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

    var availabilityInfo: AvailabilityInfo

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL?, address: String, price: Float, pDescription: String, isAvailable: Bool, isComplete: Bool, availabilityInfo: AvailabilityInfo, customerId: Int) {
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
    }

    convenience init() {
        self.init(latitude: CLLocationDegrees.init(75),
                     longitude: CLLocationDegrees.init(-135),
                     photoURL: URL.init(string: ""),
                     address: "Select a location",
                     price: 1.0,
                     pDescription: "",
                     isAvailable: true,
                     isComplete: false,
                     availabilityInfo: AvailabilityInfo.init(),
                     customerId: AppState.shared.customer.id)

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
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, price: price, pDescription: pDescription, isAvailable: isAvailable, isComplete: isComplete, availabilityInfo: availabilityInfo, customerId: customerId)

        if let identifier = parking["id"] as? Int {
            self.id = identifier
        }
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

    func scheduleAvailable(_ date: Date) -> Bool {
        let myCalendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        var weekDay = myCalendar.component(.weekday, from: date)
        let hour = myCalendar.component(.hour, from: date)
        let minute = myCalendar.component(.minute, from: date)

        // Shifting to our own date system
        if weekDay == 0 {
            weekDay = 9
        } else if weekDay == 1 {
            weekDay = 8
        }
        weekDay -= 2

        let startSplitted = availabilityInfo.startTime.components(separatedBy: ":")
        var startValid = false
        let startHour = Int(startSplitted[0])!
        let startMinute = Int(startSplitted[1])!
        if startHour == hour && startMinute < minute {
            startValid = true
        } else if startHour < hour {
            startValid = true
        }

        let stopSplitted = availabilityInfo.stopTime.components(separatedBy: ":")
        var stopValid = false
        let stopHour = Int(stopSplitted[0])!
        let stopMinute = Int(stopSplitted[1])!
        if stopHour == hour && stopMinute > minute {
            stopValid = true
        } else if stopHour > hour {
            stopValid = true
        }

        return startValid && stopValid && availabilityInfo.daysAvailable[weekDay]
    }
}

extension Parking {
    func persist(complete: @escaping (Error?) -> Void) {
        APIClient.shared.createParking(parking: self, complete: complete)
    }

    func update(complete: @escaping (Error?) -> Void) {
        APIClient.shared.updateParking(parking: self, complete: complete)
    }
    func delete(complete: @escaping (Error?) -> Void) {
        APIClient.shared.deleteParking(parking: self, complete: complete)
    }

    func toDictionary() -> [String : Any] {
        return [
            "latitude": latitude,
            "longitude": longitude,
            "photo_url": "\(photoURL!)",
            "address": address,
            "price": String.init(format: "%.2f", price),
            "description": pDescription,
            "customer_id": customerId,
            "is_available": isAvailable,
            "is_complete": isComplete,
            "availability_info": availabilityInfo.toDictionary()
        ]
    }

    class func getAllParkings(_ complete: @escaping([(Parking)], Error?) -> Void) {
        APIClient.shared.getAllParkings(complete: complete)
    }

    class func getCustomerParkings(_ complete: @escaping([(Parking)], Error?) -> Void) {
        APIClient.shared.getCustomerParkings { (parkings, error) in
            complete(parkings, error)
        }
    }
}

class AvailabilityInfo: NSObject {
    var startTime: String
    var stopTime: String
    var alwaysAvailable: Bool

    // Array of 7 elements. Index 0 represents Monday up to index 6 which represents Sunday
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
        let daysAvailable = [true, true, true, true, true, true, true]
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

    func lapsOfTimeText() -> String {
        if startTime == "0:00 AM" && startTime == "12:00 PM" {
            return "All Day"
        } else {
            return (startTime + "-" + stopTime)
        }
    }

    func startDate() -> Date {
        return AvailabilityInfo.formatter().date(from: self.startTime)!
    }

    func stopDate() -> Date {
        return AvailabilityInfo.formatter().date(from: self.stopTime)!
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

