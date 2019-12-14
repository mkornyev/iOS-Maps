//
//  PostViewModelTest.swift
//  tripbook-testsuite
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import XCTest
@testable import tripbook_app

class PostViewModelTest: XCTestCase {
  var postModel: PostViewModel!
  var testLatency: Double!
  
  override func setUp() {
    self.postModel = PostViewModel()
    self.testLatency = MapViewController.LATENCY // Global setting
  }

  func testLoadSuccess() {
    DispatchQueue.main.asyncAfter(deadline: .now() + testLatency) {
      XCTAssert(self.postModel.posts.count > 10) // Arbitrary
    }
  }

}
