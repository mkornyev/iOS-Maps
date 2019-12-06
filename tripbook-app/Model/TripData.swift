//
//  TripData.swift
//  tripbook-app
//

import Foundation
import CoreLocation
import FirebaseFirestore
import CodableFirebase

extension GeoPoint: GeoPointType {}
extension DocumentReference: DocumentReferenceType {}

class TripData {
//  let db = Firestore.firestore()
  
  // MARK: - Trip Attributes
  
  var trip_ref: String
  var from_location: String
  var to_location: String?
  var distance: Int
  var trip_data: [CLLocationCoordinate2D]
//  var tripImages: [CLLocationCoordinate2D: String]
//  var tripAnnotations: [CLLocationCoordinate2D: String]
  var start_date: Date
  var end_date: Date?
//  var visible: Bool
  var user: DocumentReference?
  
  init() {
    trip_ref = ""
    from_location = ""
    to_location = nil
    distance = 0
    trip_data = []
    start_date = Date(timeIntervalSinceReferenceDate: -123456789.0)
    end_date = nil
//    visible = false
    user = nil
  }

  // MARK: - Methods
  
  // Populates the tripData struct given a valid tripID
  public func loadTripData(_ tripID: String = "JCzEKCv9XGglmZyq8V0J") -> Void {
    
//    let myGroup = DispatchGroup()
//    myGroup.enter()
    
    let db = Firestore.firestore()
  
    let locationsRef = db.collection("trips")
    locationsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
          print("ERROR: Couldn't recieve Firestore snapshot: \(err)")
      } else {
        for document in querySnapshot!.documents {
//          print("\(document.documentID) => \(document.data())")

          if document.documentID == tripID {
            for (key, value) in document.data() {
              self.switchCase(key: key, value: value)
            }
            self.trip_ref = document.documentID
          }
        }
      }
//      if let document = document, document.exists {
//         for (key, value) in document.data()! {
//           self.switchCase(key: key, value: value)
//         }
//      } else {
//        print("ERROR: Couldn't recieve Firestore snapshot: \(err) | loadTripData() in TripData")
//      }
      
    }
//    myGroup.leave() //// When your task completes
//    myGroup.notify(queue: DispatchQueue.main) {
//      print("!!!!!!!!!!!!    DONE    !!!!!!!!!!!!")
//    }
    
//    print("***********Trip data (end of loadTripData)**************")
//    print(self.tripData.trip_data)
//    print("**********************************")
  }
  
  private func switchCase(key: String, value: Any) {
    switch key {
      case "user":
        self.user = value as! DocumentReference
        
      case "from_location":
        self.from_location = value as! String
      
      case "to_location":
        self.to_location = value as? String
      
      case "distance":
        self.distance = value as! Int
        
      case "start_date":
        let t = value as! Timestamp
        self.start_date = t.dateValue()
        
      case "end_date":
        let t = value as! Timestamp
        self.end_date = t.dateValue()
      
//      case "visible":
//        self.visible = value as! Bool
      
      case "trip_data":
        let rawArray = value as! [GeoPoint]
        self.trip_data = []
        
        for point in rawArray {
          let coord = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
          self.trip_data.append(coord)
        }
      
//        print("***********Trip data (switch)**************")
//        print(self.trip_data)
//        print(value)
//        print("**********************************")
      
      default:
        print("Invalid firebase token provided: /Model/TripData in loadTripData()")
    }
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


