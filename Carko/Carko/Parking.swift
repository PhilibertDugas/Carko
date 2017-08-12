//
//  Parking.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-04.
//  Copyright © 2016 QH4L. All rights reserved.
//

import CoreLocation
import Crashlytics

class Parking {
    var id: Int?
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photoURL: URL?
    var address: String
    var pDescription: String
    var isAvailable: Bool
    var isComplete: Bool
    var customerId: Int
    var multiplePhotoUrls: [(URL)]
    var price: Float

    var availabilityInfo: AvailabilityInfo
    var parkingAvailabilityInfo: [ParkingAvailabilityInfo?]
    var isDeleted: Bool
    var totalRevenue: Float

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, photoURL: URL?, address: String, pDescription: String, isAvailable: Bool, isComplete: Bool, availabilityInfo: AvailabilityInfo, customerId: Int, multiplePhotoUrls: [(URL)], price: Float, parkingAvailabilityInfo: [ParkingAvailabilityInfo?]) {
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.address = address
        self.pDescription = pDescription
        self.isAvailable = isAvailable
        self.availabilityInfo = availabilityInfo
        self.customerId = customerId
        self.isComplete = isComplete
        self.multiplePhotoUrls = multiplePhotoUrls
        self.price = price
        self.isDeleted = false
        self.totalRevenue = 0.0
        self.parkingAvailabilityInfo = parkingAvailabilityInfo
    }

    convenience init() {
        self.init(latitude: CLLocationDegrees.init(75), longitude: CLLocationDegrees.init(-135), photoURL: nil, address: "Select a location", pDescription: "", isAvailable: true, isComplete: false, availabilityInfo: AvailabilityInfo.init(), customerId: AuthenticationHelper.getCustomer().id, multiplePhotoUrls: [], price: 0.50, parkingAvailabilityInfo: [ParkingAvailabilityInfo.init()])
    }

    convenience init?(parking: [String : Any]) {
        guard let price = parking["price"] as? Float, let latitude = parking["latitude"] as? CLLocationDegrees, let longitude = parking["longitude"] as? CLLocationDegrees, let address = parking["address"] as? String, let pDescription = parking["description"] as? String, let isAvailable = parking["is_available"] as? Bool, let customerId = parking["customer_id"] as? Int, let isComplete = parking["is_complete"] as? Bool, let multiplePhotoString = parking["multiple_photo_urls"] as? [(String)] else { return nil }

        // TODO: Deprecated - Delete once new implementation works
        guard let info = parking["availability_info"] as? [String : Any] else { return nil }
        let availabilityInfo = AvailabilityInfo.init(availabilityInfo: info)

        let parkingAvailabilityInfo: [ParkingAvailabilityInfo?]
        if let parkingAvailabilityArray = parking["parking_availability_infos"] as? [[String : Any]] {
            parkingAvailabilityInfo = parkingAvailabilityArray.map { ParkingAvailabilityInfo.init(info: $0) }
        } else {
            parkingAvailabilityInfo = []
        }

        var photoURL: URL? = nil
        if let urlString = parking["photo_url"] as? String {
            photoURL = URL.init(string: urlString)
        }

        // FIXME: Aggressive unwrapping
        var multipleUrls: [(URL)] = []
        for element in multiplePhotoString {
            multipleUrls.append(URL.init(string: element.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        
        self.init(latitude: latitude, longitude: longitude, photoURL: photoURL, address: address, pDescription: pDescription, isAvailable: isAvailable, isComplete: isComplete, availabilityInfo: availabilityInfo, customerId: customerId, multiplePhotoUrls: multipleUrls, price: price, parkingAvailabilityInfo: parkingAvailabilityInfo)

        if let identifier = parking["id"] as? Int {
            self.id = identifier
        }
        if let totalRevenue = parking["total_revenue"] as? Float {
            self.totalRevenue = totalRevenue
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
                LocalParkingManager.shared.insertParking(parking)
            }
            complete(error)
        }
    }

    func update(complete: @escaping (Error?) -> Void) {
        APIClient.shared.updateParking(parking: self) { (error, parking) in
            if let parking = parking {
                LocalParkingManager.shared.updateParking(parking)
            }
            complete(error)
        }
    }

    func delete(complete: @escaping (Error?) -> Void) {
        APIClient.shared.deleteParking(parking: self) { (error) in
            if error == nil {
                LocalParkingManager.shared.removeParking(self)
            }
            complete(error)
        }
    }

    class func getCustomerParkings(_ complete: @escaping([(Parking?)], Error?) -> Void) {
        if !LocalParkingManager.shared.getParkings().isEmpty {
            complete(LocalParkingManager.shared.getParkings(), nil)
        } else {
            APIClient.shared.getCustomerParkings { (parkings, error) in
                if error == nil {
                    LocalParkingManager.shared.setParkings(parkings)
                }
                complete(parkings, error)
            }
        }
    }

    class func completeCustomerParkings() {
        getCustomerParkings { (parkings, error) in
            if let error = error {
                Crashlytics.sharedInstance().recordError(error)
            } else {
                let completedParkings = parkings.map({ (parking: Parking?) -> Parking? in
                    parking?.isComplete = true
                    return parking
                })
                completedParkings.forEach { parking in
                    parking?.update(complete: { (error) in
                        if let error = error {
                            Crashlytics.sharedInstance().recordError(error)
                        }
                    })
                }
            }
        }
    }

    func toDictionary() -> [String : Any] {
        var dict: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "description": pDescription,
            "is_available": isAvailable,
            "is_complete": isComplete,
            "is_deleted": isDeleted,
            "customer_id": customerId,
            "availability_info": availabilityInfo.toDictionary(),
            "multiple_photo_urls": multiplePhotoUrls.map { $0.absoluteString },
            "parking_availability_infos": parkingAvailabilityInfo.map { $0?.toDictionary() },
            "price": price
        ]
        if let url = photoURL {
            dict["photo_url"] = "\(url)"
        }
        return dict
    }
}

extension Parking: Equatable {
    public static func ==(lhs: Parking, rhs: Parking) -> Bool {
        let basicAssertion = lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.address == rhs.address &&
        lhs.pDescription == rhs.pDescription &&
        lhs.isAvailable == rhs.isAvailable &&
        lhs.isComplete == rhs.isComplete &&
        lhs.isDeleted == rhs.isDeleted &&
        lhs.customerId == rhs.customerId &&
        lhs.multiplePhotoUrls == rhs.multiplePhotoUrls
        if let leftId = lhs.id, let rightId = rhs.id {
            return basicAssertion && leftId == rightId
        } else {
            return basicAssertion
        }
    }
}

class ParkingAvailabilityInfo: NSObject {
    var startHour: String
    var stopHour: String

    var sundayAvailable: Bool
    var mondayAvailable: Bool
    var tuesdayAvailable: Bool
    var wednesdayAvailable: Bool
    var thursdayAvailable: Bool
    var fridayAvailable: Bool
    var saturdayAvailable: Bool

    var price: Float

    init(startHour: String, stopHour: String, sundayAvailable: Bool, mondayAvailable: Bool, tuesdayAvailable: Bool, wednesdayAvailable: Bool, thursdayAvailable: Bool, fridayAvailable: Bool, saturdayAvailable: Bool, price: Float) {
        self.startHour = startHour
        self.stopHour = stopHour

        self.sundayAvailable = sundayAvailable
        self.mondayAvailable = mondayAvailable
        self.tuesdayAvailable = tuesdayAvailable
        self.wednesdayAvailable = wednesdayAvailable
        self.thursdayAvailable = thursdayAvailable
        self.fridayAvailable = fridayAvailable
        self.saturdayAvailable = saturdayAvailable
        self.price = price
    }

    convenience override init() {
        let startHour = "09:00"
        let stopHour = "17:00"

        self.init(startHour: startHour, stopHour: stopHour, sundayAvailable: false, mondayAvailable: false, tuesdayAvailable: false, wednesdayAvailable: false, thursdayAvailable: false, fridayAvailable: false, saturdayAvailable: false, price: 2.00)
    }

    convenience init?(info: [String : Any]) {
        guard let startHour = info["start_hour"] as? String,
            let stopHour = info["stop_hour"] as? String,
            let sundayAvailable = info["sunday_available"] as? Bool,
            let mondayAvailable = info["monday_available"] as? Bool,
            let tuesdayAvailable = info["tuesday_available"] as? Bool,
            let wednesdayAvailable = info["wednesday_available"] as? Bool,
            let thursdayAvailable = info["thursday_available"] as? Bool,
            let fridayAvailable = info["friday_available"] as? Bool,
            let saturdayAvailable = info["saturday_available"] as? Bool,
            let price = info["price"] as? Float else { return nil }

        self.init(startHour: startHour, stopHour: stopHour, sundayAvailable: sundayAvailable, mondayAvailable: mondayAvailable, tuesdayAvailable: tuesdayAvailable, wednesdayAvailable: wednesdayAvailable, thursdayAvailable: thursdayAvailable, fridayAvailable: fridayAvailable, saturdayAvailable: saturdayAvailable, price: price)
    }

    func toDictionary() -> [String : Any] {
        return [
            "start_hour": startHour,
            "stop_hour": stopHour,
            "sunday_available": sundayAvailable,
            "monday_available": mondayAvailable,
            "tuesday_available": tuesdayAvailable,
            "wednesday_available": wednesdayAvailable,
            "thursday_available": thursdayAvailable,
            "friday_available": fridayAvailable,
            "saturday_available": saturdayAvailable,
            "price": price
        ]
    }

    func isAvailable() -> Bool {
        for day in [mondayAvailable, tuesdayAvailable, wednesdayAvailable, thursdayAvailable, fridayAvailable, saturdayAvailable, sundayAvailable] {
            if day {
                return true
            }
        }
        return false
    }

    func daysEnumerationText() -> String {
        var enumerationText = ""
        var needsPunctuation = false

        // FIXME: Translate
        if everyDayAvailable() {
            return "Everyday"
        }

        if mondayAvailable {
            enumerationText += "Mon"
            needsPunctuation = true
        }

        if tuesdayAvailable {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Tue"
            needsPunctuation = true
        }

        if wednesdayAvailable {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Wed"
            needsPunctuation = true
        }

        if thursdayAvailable {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Thr"
            needsPunctuation = true
        }

        if fridayAvailable {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Fri"
            needsPunctuation = true
        }

        if saturdayAvailable {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Sat"
            needsPunctuation = true
        }

        if sundayAvailable {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Sun"
            needsPunctuation = true
        }

        return enumerationText
    }

    private func everyDayAvailable() -> Bool {
        for day in [mondayAvailable, tuesdayAvailable, wednesdayAvailable, thursdayAvailable, fridayAvailable, saturdayAvailable, sundayAvailable] {
            if !day {
                return false
            }
        }
        return true
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

 }

