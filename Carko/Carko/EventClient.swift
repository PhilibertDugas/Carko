//
//  EventClient.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-04-20.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation
import Alamofire

extension APIClient {
    func getAllEvents(complete: @escaping([(Event)], Error?) -> Void) {
        // #warning fix error handling 
        let getUrl = baseUrl.appendingPathComponent("/events")
        request(getUrl, headers: authHeaders()).responseJSON { (response) in
            if let error = response.result.error {
                complete([], error)
            } else if let result = response.result.value {
                let eventArray = result as! NSArray
                var events = [(Event)]()
                for event in eventArray {
                    let dict = event as! [String : Any]
                    events.append(Event.init(event: dict))
                }
                complete(events, nil)
            }
        }
    }

    func getEventParkings(_ event: Event, complete: @escaping([(Parking)], Error?) -> Void) {
        let getUrl = baseUrl.appendingPathComponent("/events/\(event.id)/parkings")
        request(getUrl).responseJSON { (response) in
            if let error = response.result.error {
                complete([], error)
            } else if let result = response.result.value {
                let parkingArray = result as! NSArray
                var parkings = [(Parking)]()
                for parking in parkingArray {
                    let dict = parking as! [String : Any]
                    parkings.append(Parking.init(parking: dict))
                }
                complete(parkings, nil)
            }
        }
    }
}
