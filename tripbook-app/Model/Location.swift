//
//  Location.swift
//  iOSMaps
//
//  Created by ProfH on github, for Lab 7 of 67442.
//  Copyright © 2019 Prof H. All rights reserved.
//

import Foundation
import CoreLocation

import Firebase
import CodableFirebase

// Tracks location for the AddTripView 
class Location: NSObject {
  
//  var tripData: TripData
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var locationManager = CLLocationManager()

  override init() {
    self.latitude = 0.00
    self.longitude = 0.00
//    self.tripData = TripData()
    super.init()
  }

//  private func loadData() throws -> Void {
//    do {
//    Firestore.firestore().collection("trips").document("JCzEKCv9XGglmZyq8V0J").getDocument { document, error in
//        if let document = document {
//            let model = try FirestoreDecoder().decode(TripData.self, from: document.data()) as TripData
//            print("Model: \(model)")
//        } else {
//            print("ERROR")
//        }
//      }
//    } catch {
//      print("ERROR")
//    }
//  }
  
  func getCurrentLocationCoordinate() -> CLLocationCoordinate2D? {
    locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.distanceFilter = kCLDistanceFilterNone
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
    }
    
    if let currLocation = locationManager.location {
      self.latitude = currLocation.coordinate.latitude
      self.longitude = currLocation.coordinate.longitude
      
      let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
      return coordinate
    } else {
      return nil
    }
  }
}
