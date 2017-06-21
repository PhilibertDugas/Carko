//
//  VehiculeLicensePlateValidator.swift
//  Carko
//
//  Created by Philibert Dugas on 2017-06-21.
//  Copyright © 2017 QH4L. All rights reserved.
//

import Foundation

struct VehiculeHelper {
    static let shared = VehiculeHelper.init()

    // FIXME: Translate
    static let vehiculeColors = ["Red", "Blue", "Green", "Yellow", "White", "Black", "Orange", "Pink", "Purple", "Silver", "Grey", "Gold", "Beige", "Other"]
    
    static func isValidPlate(_ licensePlate: String) -> Bool {
        let plateRegex = try! NSRegularExpression.init(pattern: "[A-Z0-9]{6}", options: .caseInsensitive)
        let matches = plateRegex.matches(in: licensePlate, options: .reportCompletion, range: NSRange.init(location: 0, length: licensePlate.characters.count))
        return matches.count > 0
    }

    var cars: [([String: Any])] = []

    init() {
        let file = Bundle.main.url(forResource: "cars", withExtension: "json")
        let data = try! Data.init(contentsOf: file!)
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        cars = json as! [([String: Any])]
    }

    func carMakes() -> [(String)] {
        var makes: [(String)] = []
        for car in cars {
            makes.append(car["title"] as! String)
        }
        return makes
    }

    func carModels(_ make: String) -> [(String)] {
        var models: [(String)] = []
        for car in cars {
            if car["title"] as! String == make {
                for model in car["models"] as! [([String: String])] {
                    models.append(model["title"]!)
                }
            }
        }
        return models
    }
}
