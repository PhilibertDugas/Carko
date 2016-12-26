//
//  Vehicule.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-12-18.
//  Copyright © 2016 QH4L. All rights reserved.
//

import Foundation

class Vehicule {
    var license: String
    var make: String
    var model: String
    var year: String
    var color: String
    var province: String

    init(license: String, make: String, model: String, year: String, color: String, province: String) {
        self.license = license
        self.make = make
        self.model = model
        self.year = year
        self.color = color
        self.province = province
    }

    convenience init(vehicule: [String: Any]) {
        let license = vehicule["license_plate"] as! String
        let make = vehicule["make"] as! String
        let model = vehicule["model"] as! String
        let year = vehicule["year"] as! String
        let color = vehicule["color"] as! String
        let province = vehicule["province"] as! String
        self.init(license: license, make: make, model: model, year: year, color: color, province: province)
    }

    func toDictionary() -> [String: Any] {
        return [
            "license_plate": license,
            "make": make,
            "model": model,
            "year": year,
            "color": color,
            "province": province
        ]
    }

    func persist(completion: @escaping (Error?) -> Void) {
        CarkoAPIClient.shared.postVehicule(vehicule: self, complete: completion)
    }
}

extension Vehicule: CustomStringConvertible {
    var description: String {
        return "\(make) \(model) \(year)"
    }
}
