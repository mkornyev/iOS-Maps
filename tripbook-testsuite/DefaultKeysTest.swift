//
//  DefaultKeysTest.swift
//  tripbook-testsuite
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import XCTest
@testable import tripbook_app

class DefaultKeysTest: XCTestCase {
  
  override func setUp() { }
  
  func testStaticFields() {
    XCTAssert(DefaultKeys.postsCollection == "posts")
    XCTAssert(DefaultKeys.tripsCollection == "trips")
    XCTAssert(DefaultKeys.imagesFolder == "userImages")
    XCTAssert(DefaultKeys.userRefString == "jTwrnfSpEiOFVmnYyFtg")
  }
  
}
