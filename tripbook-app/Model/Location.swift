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
  var coordinate: CLLocationCoordinate2D?
  var locationManager = CLLocationManager()

  override init() {
    self.coordinate = nil
    super.init()
    
    getCurrentLocation()
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
  
  func getCurrentLocation() -> Void {
    locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.distanceFilter = kCLDistanceFilterNone
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
    }
    
    if let currLocation = locationManager.location {
      let latitude = currLocation.coordinate.latitude
      let longitude = currLocation.coordinate.longitude
      
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    } else {
      print("Unable to grab location")
      self.coordinate = nil
    }
  }
}
