//
//  LocationTest.swift
//  tripbook-testsuite
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import XCTest
@testable import tripbook_app


// MARK: - NOTE: ** This test class MAY SOMETIMES FAIL ** 

class LocationTest: XCTestCase {
  
    var location: Location!
    var testLatency: Double!
  
    override func setUp() {
      self.location = Location()
      self.testLatency = MapViewController.LATENCY
    }

    func testLocationLoading() {
      location.getCurrentLocation()
      DispatchQueue.main.asyncAfter(deadline: .now() + testLatency) {
        XCTAssert(self.location.coordinate != nil)
      }
    }

}
