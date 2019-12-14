//
//  FriendsViewModelTest.swift
//  tripbook-testsuite
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import XCTest
@testable import tripbook_app

class FriendsViewModelTest: XCTestCase {
  var friendsModel: FriendsViewModel!
  var testLatency: Double!
  
  override func setUp() {
    self.friendsModel = FriendsViewModel()
    self.testLatency = MapViewController.LATENCY // Global setting
  }

  func testLoadSuccess() {
    DispatchQueue.main.asyncAfter(deadline: .now() + testLatency) {
      XCTAssert(self.friendsModel.posts.count > 10) // Arbitrary
      print("\n\n\n\n FRIENDS VM: \(self.friendsModel.posts) \n\n\n\n")
    }
  }

}
