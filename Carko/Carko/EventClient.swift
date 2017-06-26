//
//  EventClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-20.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics

extension APIClient {
    func getAllEvents(complete: @escaping([(Event?)], Error?) -> Void) {
        // #warning fix error handling 
        let getUrl = baseUrl.appendingPathComponent("/events")
        request(getUrl).responseJSON { (response) in
            if let error = response.result.error {
                complete([], error)
            } else if let result = response.result.value {
                guard let eventArray = result as? NSArray else { return }
                var events = [(Event?)]()
                for event in eventArray {
                    guard let dict = event as? [String : Any] else {
                        Crashlytics.sharedInstance().recordError(NSError.init(domain: "Received bad getAllEvents data", code: 0, userInfo: nil))
                        continue
                    }
                    events.append(Event.init(event: dict))
                }
                complete(events, nil)
            }
        }
    }

    func getEventParkings(_ event: Event, complete: @escaping([(Parking?)], Error?) -> Void) {
        let getUrl = baseUrl.appendingPathComponent("/events/\(event.id)/parkings")
        request(getUrl).responseJSON { (response) in
            if let error = response.result.error {
                complete([], error)
            } else if let result = response.result.value {
                guard let parkingArray = result as? NSArray else { return }
                var parkings: [(Parking?)] = []
                for parking in parkingArray {
                    guard let dict = parking as? [String : Any] else {
                        Crashlytics.sharedInstance().recordError(NSError.init(domain: "Received bad getEventParkings data", code: 0, userInfo: nil))
                        continue
                    }
                    parkings.append(Parking.init(parking: dict))
                }
                complete(parkings, nil)
            }
        }
    }
}
