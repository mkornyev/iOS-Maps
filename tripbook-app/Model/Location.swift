//
//  Location.swift
//  tripbook-app
//

import Foundation
import CoreLocation

import Firebase

// Tracks location for the AddTripView
class Location: NSObject {
  
  private var locationManager = CLLocationManager()
  var coordinate: CLLocationCoordinate2D?

  override init() {
    self.coordinate = nil
    super.init()
    
    getCurrentLocation()
  }
  
  // Func that either sets self.coordinate to nil, or to a valid location
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
      print("\nERROR: Unable to grab location")
      self.coordinate = nil
    }
  }
}

