//
//  TripDataTest.swift
//  tripbook-testsuite
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import XCTest
@testable import tripbook_app


class TripDataTest: XCTestCase {
  
    var data: TripData!
    var tripID: String!
    var inceptionDate: Date!
    var testLatency: Double!
  
    override func setUp() {
      self.data = TripData()
      self.tripID = "JCzEKCv9XGglmZyq8V0J"
      self.inceptionDate = Date(timeIntervalSinceReferenceDate: -123456789.0)
      self.testLatency = MapViewController.LATENCY
    }

    func testInits() {
      XCTAssert(data.trip_ref == "")
      XCTAssert(data.from_location == "")
      XCTAssert(data.to_location == nil)
      XCTAssert(data.distance == 0)
      XCTAssert(data.trip_data.count == 0)
      XCTAssert(data.image_coordinates.count == 0)
      XCTAssert(data.images.count == 0)
      XCTAssert(data.annotation_coordinates.count == 0)
      XCTAssert(data.annotations.count == 0)
      XCTAssert(data.start_date == inceptionDate)
      XCTAssert(data.end_date == nil)
      XCTAssert(data.user == "")
    }
  
    func testCompleteTripLoading() {
      data.loadTripData(tripID)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + testLatency) {
        XCTAssert(self.data.trip_ref == "")  // Set in VC load
        XCTAssert(self.data.from_location == "Morewood")
        XCTAssert(self.data.to_location == "Somewhere far away...")
        XCTAssert(self.data.distance == 54)
        
        XCTAssert(self.data.trip_data.count == 1)
        XCTAssert(self.data.trip_data[0].latitude == 43.129381)
        XCTAssert(self.data.trip_data[0].longitude == -79.27136)
        
        XCTAssert(self.data.image_coordinates.count == 1)
        XCTAssert(self.data.image_coordinates[0].latitude == 43.129381)
        XCTAssert(self.data.image_coordinates[0].longitude == -79.27136)
        
        XCTAssert(self.data.images.count == 1)
        XCTAssert(self.data.images[0].absoluteString == "www.google.com/sample_img")
        
        XCTAssert(self.data.annotations.count == 1)
        XCTAssert(self.data.annotations[0] == "Met up with a friend")
        
        XCTAssert(self.data.annotation_coordinates.count == 1)
        XCTAssert(self.data.annotation_coordinates[0].latitude == 43.129381)
        XCTAssert(self.data.annotation_coordinates[0].longitude == -79.27136)
              
        XCTAssert(4 == Calendar.current.component(.weekday, from: self.data.start_date))
        XCTAssert(5 == Calendar.current.component(.weekday, from: self.data.end_date!))
        XCTAssert(self.data.user == "users/jTwrnfSpEiOFVmnYyFtg") // Set in VC
      }
    }

}
