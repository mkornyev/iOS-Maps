//
//  TripData.swift
//  iOSMaps
//
//  Created by Max Kornyev on 11/3/19.
//  Copyright © 2019 Max Kornyev. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import CodableFirebase

extension GeoPoint: GeoPointType {}

public struct TripData: Codable {
//  let db = Firestore.firestore()
//  var firstTimeUser = true
  
  var fromLocation: String
  var toLocation: String?
  var distance: Int
  var tripData: [GeoPoint: GeoPoint] // Store as coordinate?
//  var tripImages: [CLLocationCoordinate2D: String]
//  var tripAnnotations: [CLLocationCoordinate2D: String]
  var startDate: Date
  var endDate: Date?
  var visible: Bool
  
  enum CodingKeys: String, CodingKey {
    case fromLocation = "from_location"
    case toLocation = "to_location"
    case distance = "distance"
    case tripData = "trip_data"
//    case tripImages = "trip_images"
//    case tripAnnotations = "trip_annotations"
    case startDate = "start_date"
    case endDate = "end_date"
    case visible = "visible"
  }
  
  
}




// Makes firebase call to load Tripdata
//func reloadData(forUser: Int) -> Void {
//
//  // *** Filter on trips w/no end date for the currentUser here
//  // let user = "/users/" + "/users/jTwrnfSpEiOFVmnYyFtg"
//
//  // Firebase issue: cannot filter on reference type
//  db.collection("trips").whereField("end_date", isEqualTo: "")
//      .getDocuments() { (querySnapshot, err) in
//          if let err = err {
//              print("Error getting documents: \(err)")
//          } else {
//              print("GOT DOCS")
//              for doc in querySnapshot!.documents {
//                // FIND A WAY TO FILTER MOST RECENT TRIP
//                if doc.documentID == "JCzEKCv9XGglmZyq8V0J" {
//                  self.fromLocation = doc.data()["from_location"] as? (String)
//                  self.toLocation = doc.data()["from_location"] as! String?
//                  self.distance = doc.data()["distance"] as? (Int)
//
//                  let tripCoords = doc.data()["trip_data"] as! [[Double]]
//                  self.tripData = tripCoords.map {  CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
//
//                  //                    var tripImages: [CLLocationCoordinate2D: String]
//                  //                    var tripAnnotations: [CLLocationCoordinate2D: String]
//
//                  self.startDate = doc.data()["start_date"] as? (Date)
//                  self.endDate = doc.data()["end_date"] as! Date?
//                  self.visible = doc.data()["visible"] as? (Bool)
//
//                  print("------")
//                  print("Going from \(self.fromLocation)")
//                  print("------")
//                }
//              }
//          }
//  }
//
//
//}
