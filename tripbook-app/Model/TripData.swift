//
//  TripData.swift
//  tripbook-app
//

import Foundation
import CoreLocation
import FirebaseFirestore
import CodableFirebase

extension GeoPoint: GeoPointType {}

class TripData {
//  let db = Firestore.firestore()
  
  var from_location: String
  var to_location: String?
  var distance: Int
  var trip_data: [CLLocationCoordinate2D]
//  var tripImages: [CLLocationCoordinate2D: String]
//  var tripAnnotations: [CLLocationCoordinate2D: String]
  var start_date: Date
  var end_date: Date?
  var visible: Bool
  var user: String
  
  init() {
    from_location = ""
    to_location = nil
    distance = 0
    trip_data = []
    start_date = Date(timeIntervalSinceReferenceDate: -123456789.0)
    end_date = nil
    visible = false
    user = ""
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


