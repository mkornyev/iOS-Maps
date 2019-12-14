//
//  CLLocationEquatableTest.swift
//  tripbook-testsuite
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import XCTest
import MapKit
@testable import tripbook_app


class CLLocationEquatableTest: XCTestCase {

  var coordA: CLLocationCoordinate2D!
  var coordB: CLLocationCoordinate2D!
  var coordC: CLLocationCoordinate2D!
  var coordD: CLLocationCoordinate2D!

  override func setUp() {
    self.coordA = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
    self.coordB = CLLocationCoordinate2D(latitude: 2.2, longitude: 1.0)
    self.coordC = CLLocationCoordinate2D(latitude: 1.0, longitude: 2.2)
    self.coordD = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
  }

  func testEquality() {
    XCTAssert(coordA == coordD)
  }

  func testIdentity() {
    XCTAssert(coordA == coordA)
    XCTAssert(coordB == coordB)
    XCTAssert(coordC == coordC)
    XCTAssert(coordD == coordD)
  }

  func testInEquality() {
    XCTAssert(coordA != coordB)
    XCTAssert(coordB != coordC)
    XCTAssert(coordC != coordD)
  }

}
