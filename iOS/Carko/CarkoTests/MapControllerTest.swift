//
//  MapControllerTest.swift
//  Carko
//
//  Created by Philibert Dugas on 2016-10-02.
//  Copyright © 2016 QH4L. All rights reserved.
//

import XCTest
@testable import Carko

class MapControllerTest: XCTestCase {
    
    var mapController: MapController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        mapController = storyboard.instantiateViewController(withIdentifier: "mapController") as! MapController
        UIApplication.shared.keyWindow!.rootViewController = mapController
        
        let _ = mapController.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMapExists() {
        let mapView = mapController.mapView
        XCTAssertNotNil(mapView)
    }
}
