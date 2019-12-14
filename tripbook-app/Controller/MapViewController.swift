//
//  MapViewController.swift
//  tripbook-app
//
//  Created by Max Kornyev on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore
import FirebaseStorage
import Kingfisher

class MapViewController: UIViewController {
  
  // MARK: - State Vars
  
  static var LATENCY:Double = 4
  static let userRefString = "jTwrnfSpEiOFVmnYyFtg" // WILL ADD A PLIST VAL FOR THIS
  let resizedImgWidth = CGFloat(50.0)
  let resizedImgBorder = CGFloat(10.0)
  
  // Hard coded vars for randomly generated movement
  static var GENERATE_RANDOM_MOVEMENT = false
  static var RANDOM_MOVEMENT_INCREMENT = 0.001
  
  // MARK: - Models & Button Models
  
  private var location: Location = Location()
  var mapView: MKMapView!
  var tripData:TripData
  var tripLogger: Timer?
  let loggerInterval = 5.0
  var newTrip = UIButton()
  var addText = UIButton()
  var addImage = UIButton()
  var stopTrip = UIButton()
  
  // MARK: - Inits

  init(tripData: TripData) {
    self.tripData = tripData
    super.init(nibName: nil, bundle: nil) // Must come last
  }
  
  required init?(coder: NSCoder) {
    fatalError("Failed to init tripData")
  }
  
  // MARK: - Methods
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.loadTrip()
    self.mapView = MKMapView()
    frameMapView()
    self.view.addSubview(mapView)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + MapViewController.LATENCY) {
      if self.tripData.from_location == "" {
        // NEW TRIP
        self.centerMap(onUser: true) // Sets span & region, centers map, and sets an annotation startpoint
        self.showCreateTools() // Show new trip annotations
      } else {
        // ONGOING TRIP
        self.beginTripLogging()
        self.drawPolyline(self.tripData.trip_data) // Draws polyline from data, sets an annotation endpoint
        self.centerMap(onUser: false) // Center on trip
        if (MapViewController.userRefString == self.tripData.user) { self.showEditTools() }
      }
    }
    mapView.delegate = self
    mapView.showsUserLocation = true
  }
  
  func frameMapView() -> Void {
    let leftMargin:CGFloat = 0
    let topMargin:CGFloat = 0
    let mapWidth:CGFloat = view.frame.size.width
    let mapHeight:CGFloat = view.frame.size.height
        
    self.mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
    self.mapView.isZoomEnabled = true
    self.mapView.isScrollEnabled = true
  }
  
  // Throws alert if no location recieved
  func centerMap(onUser: Bool) -> Void {
    location.getCurrentLocation()
    
    if onUser {
      if let coordinate = location.coordinate {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        setAnnotation(coordinate, title: "", subTitle: "You're here!")
      }
      else {
        let alert = UIAlertController(title: "Alert", message: "You are on Airplane mode. Refresh the app and try again.", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        // **ON DISMISS: Navigate back to Feed View
      }
    } else {
      let data = self.tripData.trip_data
      
      let diff1 = abs(data.first!.latitude - data.last!.latitude) * 1.8
      let diff2 = abs(data.first!.longitude - data.last!.longitude) * 1.8
      
      let latDelta = diff1
      let longDelta = diff2
      let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
      
      let coordinate = data[(data.count - 1) / 2]
      let region = MKCoordinateRegion(center: coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
    }
  }

  // Loads trip for current user
  private func loadTrip() -> Void {
    let db = Firestore.firestore()
    let userRefString = "jTwrnfSpEiOFVmnYyFtg" // WILL ADD A PLIST VAL FOR THIS
    let userRef = Firestore.firestore().collection("users").document(userRefString)
    let mostRecentTripRef = db.collection("trips").whereField("user", isEqualTo: userRef).order(by: "start_date", descending: true).limit(to: 1)
    
    mostRecentTripRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error receiving Firestore snapshot: \(err) | loadTrip() in ContentView")
        self.tripData.loadTripData()
      } else {
        if querySnapshot!.documents.count == 0 { print("ERROR: Did not get any documents for filter | loadTrip() in ContentView") }
        
        for document in querySnapshot!.documents {
          if let str = document.data()["to_location"] as? String {
            if str == "" {
              self.tripData.loadTripData(document.documentID)
            }
          }
          else {
            self.tripData.loadTripData(document.documentID)
          }
        }
      }
    }
  }
}

//MARK: - Trip Logging Section

extension MapViewController {
  
  func beginTripLogging() {
    location.getCurrentLocation()
    
    // Set start coordinate
    if let coord = location.coordinate {
      tripData.trip_data.append(coord)
      setAnnotation(coord, title: "Your Location", subTitle: "All Roads Start Somewhere")
    }
    
    // Set trip struct
    tripData.user = MapViewController.userRefString
    tripData.distance = 0
    tripData.start_date = Date()
    
    // Start Logger
    self.tripLogger = Timer.scheduledTimer(timeInterval: self.loggerInterval, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
  }
  
  @objc func fire()
  {
    print("FIRED")
    
    // Get location if possible
    location.getCurrentLocation()
    if let coord = location.coordinate  {
      if tripData.trip_data.count > 1 {
        let lastCoord = self.tripData.trip_data.last!
        
        // For auto generated movement
        if MapViewController.GENERATE_RANDOM_MOVEMENT {
          let newcoord = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude + MapViewController.RANDOM_MOVEMENT_INCREMENT)
          MapViewController.RANDOM_MOVEMENT_INCREMENT = MapViewController.RANDOM_MOVEMENT_INCREMENT * 2
          tripData.trip_data.append(newcoord)
        } else {
          if lastCoord.latitude != coord.latitude && lastCoord.longitude != coord.longitude { tripData.trip_data.append(coord) }
        }
      }
      else if tripData.trip_data.count == 1 { tripData.trip_data.append(coord) }
    }
    
    // Log location to Firestore ONLY if needed
    var a_coords:[GeoPoint] = []
    for coord in tripData.annotation_coordinates {
      a_coords.append(GeoPoint(latitude: coord.latitude, longitude: coord.longitude))
    }
    
//    var i_coords:[GeoPoint] = []
//    for coord in tripData.image_coordinates {
//      i_coords.append(GeoPoint(latitude: coord.latitude, longitude: coord.longitude))
//    }
    
    var t_coords:[GeoPoint] = []
    for coord in tripData.trip_data {
      t_coords.append(GeoPoint(latitude: coord.latitude, longitude: coord.longitude))
    }
    
    let user_ref = Firestore.firestore().collection("users").document(self.tripData.user);
    
    let data: [String: Any] = [
        "annotation_coordinates": a_coords,
        "annotations": tripData.annotations,
//        "distance": tripData.distance, // SET ON TRIP END
//        "end_date": tripData.end_date,
        "from_location": tripData.from_location,
//        "image_coordinates": i_coords, // ALREADY SET IN POST
        // "images": tripData.images, // ALREADY SET
        "start_date": Timestamp(date: tripData.start_date),
//        "to_location": tripData.to_location, // SET ON TRIP END
        "trip_data": t_coords,
        "user": user_ref
//        "user": tripData.user.contains("/users/") ? tripData.user : "/users/" + tripData.user
    ]
    
    if self.tripData.trip_ref == "" {
      var ref: DocumentReference? = nil
      ref = Firestore.firestore().collection("trips").addDocument(data: data) { err in
        if err != nil {
          fatalError("Could not save trip. Turn off airplane mode.")
        } else {
          self.tripData.trip_ref = ref!.documentID
        }
      }
    } else {
      Firestore.firestore().collection("trips").document(self.tripData.trip_ref).setData(data) { err in
        if err != nil {
          fatalError("Could not save trip. Turn off airplane mode.")
        }
      }
    }
    // Redraw polyline
    self.drawPolyline(self.tripData.trip_data)
  }
}

// MARK: - Mock Helper Code
//extension MapViewController {
//  func populateRoute(_ tripID: String = "") -> Void {
//    let tripCoords: [[Double]]
//
//    if tripID == "" {
//      self.from_location = "Morewood"
//      self.to_location = nil
//      self.distance = 1
//      self.start_date = Date(timeIntervalSinceReferenceDate: -123456789.0)
//      self.end_date = nil
//      self.visible = false
//      self.user = "jTwrnfSpEiOFVmnYyFtg"
//      self.trip_data = []
//      //  var tripImages: [CLLocationCoordinate2D: String]
//      //  var tripAnnotations: [CLLocationCoordinate2D: String]
//
//      tripCoords = [
//        [40.4446433, -79.9430155],
//        [40.4446515, -79.943509],
//        [40.4446351, -79.9441098],
//        [40.4445861, -79.9449574],
//        [40.4445453, -79.9457942],
//        [40.4445372, -79.946674],
//        [40.4450597, -79.9464809],
//        [40.4455986, -79.9466311],
//        [40.4462028, -79.9469315],
//        [40.4467988, -79.9471461],
//        [40.4472071, -79.9473714],
//      ]
//    } else {
//      self.from_location = "x"
//      self.to_location = "y"
//      self.distance = 4
//      self.start_date = Date(timeIntervalSinceReferenceDate: -13456789.0)
//      self.end_date = Date(timeIntervalSinceReferenceDate: -13453789.0)
//      self.visible = true
//      self.user = "jTwrnfSpEiOFVmnYyFtg"
//      self.trip_data = []
//      //  var tripImages: [CLLocationCoordinate2D: String]
//      //  var tripAnnotations: [CLLocationCoordinate2D: String]
//
//      tripCoords = [
//        [40.4446433, -79.9430155],
//        [40.4446515, -79.943509],
//        [40.4446351, -79.9441098],
//        [40.4445861, -79.9449574],
//        [40.4445453, -79.9457942],
//        [40.4445372, -79.946674],
//        [40.4450597, -79.9464809],
//        [40.4455986, -79.9466311],
//        [40.4462028, -79.9469315],
//        [40.4467988, -79.9471461],
//        [40.4472071, -79.9473714],
//      ]
//    }
//
//    for arr in tripCoords {
//      let coord = CLLocationCoordinate2D(latitude: arr[0], longitude: arr[1])
//      self.trip_data.append(coord)
//    }
//
//    print("++++++++++++++++ in populateRoute ++++++++++++")
//    print(self.user)
//    print(self.trip_data)
//    print("++++++++++++++++++++++++++++")
//  }
//}






//func populateRoute(_ tripID: String = "") -> TripData {
//  let tripCoords: [[Double]]
//  let data = TripData()
//
//  if tripID == "" {
//    data.from_location = "Morewood"
//    data.to_location = nil
//    data.distance = 1
//    data.start_date = Date(timeIntervalSinceReferenceDate: -123456789.0)
//    data.end_date = nil
//    data.visible = false
//    data.user = "jTwrnfSpEiOFVmnYyFtg"
//    data.trip_data = []
//    //  var tripImages: [CLLocationCoordinate2D: String]
//    //  var tripAnnotations: [CLLocationCoordinate2D: String]
//
//    tripCoords = [
//      [40.4446433, -79.9430155],
//      [40.4446515, -79.943509],
//      [40.4446351, -79.9441098],
//      [40.4445861, -79.9449574],
//      [40.4445453, -79.9457942],
//      [40.4445372, -79.946674],
//      [40.4450597, -79.9464809],
//      [40.4455986, -79.9466311],
//      [40.4462028, -79.9469315],
//      [40.4467988, -79.9471461],
//      [40.4472071, -79.9473714],
//    ]
//  } else {
//    data.from_location = "x"
//    data.to_location = "y"
//    data.distance = 4
//    data.start_date = Date(timeIntervalSinceReferenceDate: -13456789.0)
//    data.end_date = Date(timeIntervalSinceReferenceDate: -13453789.0)
//    data.visible = true
//    data.user = "jTwrnfSpEiOFVmnYyFtg"
//    data.trip_data = []
//    //  var tripImages: [CLLocationCoordinate2D: String]
//    //  var tripAnnotations: [CLLocationCoordinate2D: String]
//
//    tripCoords = [
//      [40.4446433, -79.9430155],
//      [40.4446515, -79.943509],
//      [40.4446351, -79.9441098],
//      [40.4445861, -79.9449574],
//      [40.4445453, -79.9457942],
//      [40.4445372, -79.946674],
//      [40.4450597, -79.9464809],
//      [40.4455986, -79.9466311],
//      [40.4462028, -79.9469315],
//      [40.4467988, -79.9471461],
//      [40.4472071, -79.9473714],
//    ]
//  }
//
//  for arr in tripCoords {
//    let coord = CLLocationCoordinate2D(latitude: arr[0], longitude: arr[1])
//    data.trip_data.append(coord)
//  }
//
//  print("++++++++++++++++ in populateRoute ++++++++++++")
//  print(data.user)
//  print(data.trip_data)
//  print("++++++++++++++++++++++++++++")
//
//  return data
//}
//
//func getRouteData() -> [CLLocationCoordinate2D] {
//  let tripCoords: [[Double]]
//  var retCoords: [CLLocationCoordinate2D] = []
//
//  tripCoords = [
//    [40.4446433, -79.9430155],
//    [40.4446515, -79.943509],
//    [40.4446351, -79.9441098],
//    [40.4445861, -79.9449574],
//    [40.4445453, -79.9457942],
//    [40.4445372, -79.946674],
//    [40.4450597, -79.9464809],
//    [40.4455986, -79.9466311],
//    [40.4462028, -79.9469315],
//    [40.4467988, -79.9471461],
//    [40.4472071, -79.9473714],
//  ]
//  for arr in tripCoords {
//    let coord = CLLocationCoordinate2D(latitude: arr[0], longitude: arr[1])
//    retCoords.append(coord)
//  }
//
//  return retCoords
//}
//
//

