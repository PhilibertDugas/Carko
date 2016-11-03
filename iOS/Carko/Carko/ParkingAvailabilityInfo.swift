//
//  ParkingAvailabilityInfo.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class ParkingAvailabilityInfo: NSObject {
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

        super.init()
    }
    
    convenience init(availabilityInfo: [String : Any]) {
        let startTime = availabilityInfo["startTime"] as! String
        let stopTime = availabilityInfo["stopTime"] as! String
        let daysAvailable = availabilityInfo["daysAvailable"] as! [(Bool)]
        let alwaysAvailable = availabilityInfo["alwaysAvailable"] as! Bool

        self.init(alwaysAvailable: alwaysAvailable, startTime: startTime, stopTime: stopTime, daysAvailable: daysAvailable)
    }
    
    convenience override init() {
        let startTime = "0:00 AM"
        let stopTime = "12:00 PM"
        let daysAvailable = [false, false, false, false, false, false, false]
        let alwaysAvailable = false

        self.init(alwaysAvailable: alwaysAvailable, startTime: startTime, stopTime: stopTime, daysAvailable: daysAvailable)
    }
    
    func toDictionary() -> [String : Any] {
        return ["alwaysAvailable": alwaysAvailable, "startTime": startTime, "stopTime": stopTime, "daysAvailable": daysAvailable]
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
