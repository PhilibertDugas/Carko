//
//  ParkingAvailabilityInfo.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class ParkingAvailabilityInfo: NSObject {
    var alwaysAvailable: Bool
    
    var startTime: String
    var stopTime: String
    
    var isMonday: Bool
    var isTuesday: Bool
    var isWednesday: Bool
    var isThursday: Bool
    var isFriday: Bool
    var isSaturday: Bool
    var isSunday: Bool
    
    init(alwaysAvailable: Bool, startTime: String, stopTime: String, isMonday: Bool, isTuesday: Bool, isWednesday: Bool, isThursday: Bool, isFriday: Bool, isSaturday: Bool, isSunday: Bool) {
        self.alwaysAvailable = alwaysAvailable
        
        self.startTime = startTime
        self.stopTime = stopTime
        
        self.isMonday = isMonday
        self.isTuesday = isTuesday
        self.isWednesday = isWednesday
        self.isThursday = isThursday
        self.isFriday = isFriday
        self.isSaturday = isSaturday
        self.isSunday = isSunday
        
        super.init()
    }
    
    convenience init(availabilityInfo: [String : Any]) {
        let startTime = availabilityInfo["startTime"] as! String
        let stopTime = availabilityInfo["stopTime"] as! String
        let isMonday = availabilityInfo["isMonday"] as! Bool
        let isTuesday = availabilityInfo["isTuesday"] as! Bool
        let isWednesday = availabilityInfo["isWednesday"] as! Bool
        let isThursday = availabilityInfo["isThursday"] as! Bool
        let isFriday = availabilityInfo["isFriday"] as! Bool
        let isSaturday = availabilityInfo["isSaturday"] as! Bool
        let isSunday = availabilityInfo["isSunday"] as! Bool
        let alwaysAvailable = availabilityInfo["alwaysAvailable"] as! Bool
        
        self.init(alwaysAvailable: alwaysAvailable, startTime: startTime, stopTime: stopTime, isMonday: isMonday, isTuesday: isTuesday, isWednesday: isWednesday, isThursday: isThursday, isFriday: isFriday, isSaturday: isSaturday, isSunday: isSunday)
    }
    
    convenience override init() {
        let startTime = "0:00 AM"
        let stopTime = "12:00 PM"
        let isMonday = false
        let isTuesday = false
        let isWednesday = false
        let isThursday = false
        let isFriday = false
        let isSaturday = false
        let isSunday = false
        let alwaysAvailable = false

        self.init(alwaysAvailable: alwaysAvailable, startTime: startTime, stopTime: stopTime, isMonday: isMonday, isTuesday: isTuesday, isWednesday: isWednesday, isThursday: isThursday, isFriday: isFriday, isSaturday: isSaturday, isSunday: isSunday)
    }
    
    func toDictionary() -> [String : Any] {
        return ["alwaysAvailable": alwaysAvailable, "startTime": startTime, "stopTime": stopTime, "isMonday": isMonday, "isTuesday": isTuesday, "isWednesday": isWednesday, "isThursday": isThursday, "isFriday": isFriday, "isSaturday": isSaturday, "isSunday": isSunday]
    }
    
    func lapsOfTimeText() -> String {
        if startTime == "0:00 AM" && startTime == "12:00 PM" {
            return "All Day"
        } else {
            return (startTime + "-" + stopTime)
        }
    }
    
    func daysEnumerationText() -> String {
        var enumerationText = ""
        var needsPunctuation = false
        
        if isMonday && isTuesday && isWednesday && isThursday && isFriday && isSaturday && isSunday {
            return "Everyday"
        }
        
        if isMonday {
            enumerationText += "Mon"
            needsPunctuation = true
        }
        
        if isTuesday {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Tue"
            needsPunctuation = true
        }
        
        if isWednesday {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Wed"
            needsPunctuation = true
        }
        
        if isThursday {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Thr"
            needsPunctuation = true
        }
        
        if isFriday {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Fri"
            needsPunctuation = true
        }
        
        if isSaturday {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Sat"
            needsPunctuation = true
        }
        
        if isSunday {
            if needsPunctuation {
                enumerationText += ", "
            }
            enumerationText += "Sun"
            needsPunctuation = true
        }
        
        return enumerationText
    }
}
