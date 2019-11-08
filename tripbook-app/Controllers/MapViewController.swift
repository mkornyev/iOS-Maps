//
//  MapViewController.swift
//  tripbook-app
//
//  Created by Max Kornyev on 11/6/19.
//  Copyright © 2019 Max Kornyev. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore
import CodableFirebase

class MapViewController: UIViewController {
  // MARK: - Passed State Vars

  var tripID: String
  var editView: Bool
  var loadTrip: Bool
  
  // MARK: - Models
  
  var location: Location = Location()
  var mapView: MKMapView!
  var tripData = TripData()
  var route = [CLLocationCoordinate2D]() // dummy data
  
  // MARK: - Inits
  
  init(tripID: String, editView: Bool, loadTrip: Bool) {
    self.tripID = tripID
    self.editView = editView
    self.loadTrip = loadTrip
    
//    if loadTrip {
//      syncDispatch.notify(queue: .main) {
//        self.loadTripData()
//      }
//    }
    
    super.init(nibName: nil, bundle: nil) // Must come last
  }
  
  required init?(coder: NSCoder) {
    fatalError("Failed to init?() tripData")
  }
  
  // MARK: - Methods
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if loadTrip {
//      self.loadTripData()
      
      // The above async call takes too long (it only populates the data after viewDidLoad runs)
      // so I populate data directly:
      print(self.tripData)
      self.tripData = populateRoute()
      print(self.tripData)
    } else {
//      self.loadTripData(self.tripID)
      
      self.tripData = populateRoute(self.tripID)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.mapView = MKMapView()
    frameMapView()
    
    // REMOVE
    print(self.tripData.user)
    print(self.tripData.end_date)
    print(self.tripData.trip_data)
    
    print("Test: \(populateRoute().end_date)")
    
    // REMOVE populate call, replace w/tripData
    if self.tripData.user == nil { // No trip loaded
      centerMap(onUser: true) // Sets span & region, centers map, and sets an annotation startpoint
      
      // provide basic map tools
    }
    else if populateRoute().end_date == nil { // Ongoing trip
      print("------------------------------------------------------")
      print("Trip is ongoing")
      print("------------------------------------------------------")
      
      drawPolyline() // Draws polyline from data, sets an annotation endpoint
      centerMap(onUser: false) // Center on trip
      // show edit tools
    }
    else { // Posted trip
      drawPolyline()
      centerMap(onUser: false)
      // show annotations (ie label overlay)
    }
    
    self.view.addSubview(mapView)
    mapView.delegate = self
  }
  
  func frameMapView() -> Void {
    let leftMargin:CGFloat = 0
    let topMargin:CGFloat = -20
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
        
        let span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        setAnnotation(coordinate: coordinate, title: "", subTitle: "You're here!")
      }
      else {
        let alert = UIAlertController(title: "Alert", message: "You are on Airplane mode. Refresh the app and try again.", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        // **ON DISMISS: Navigate back to Feed View
      }
    } else {
//      let data = self.tripData.trip_data!
      // REMOVE
      let data = populateRoute().trip_data!
      let latDelta = data.first!.latitude - data.last!.latitude
      let longDelta = data.first!.longitude - data.last!.longitude
      let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
      
      let coordinate = data[(data.count - 1) / 2]
      let region = MKCoordinateRegion(center: coordinate, span: span)
      self.mapView.setRegion(region, animated: true)
    }
  }
  
  func drawPolyline() -> Void {
    let polyline = MKPolyline(coordinates: tripData.trip_data!, count: tripData.trip_data!.count)
    self.mapView.addOverlay(polyline)
    
    setAnnotation(coordinate: tripData.trip_data!.first!, title: tripData.from_location!, subTitle: "All roads start somewhere...")
    setAnnotation(coordinate: tripData.trip_data!.last!, title: tripData.to_location!, subTitle: "Is that as far as you're gonna go?")
  }
  
  func setAnnotation(coordinate: CLLocationCoordinate2D, title: String, subTitle: String) -> Void {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title
    annotation.subtitle = subTitle
    mapView.addAnnotation(annotation)
  }
}

extension MapViewController {
  
  func loadTripData(_ tripID: String = "JCzEKCv9XGglmZyq8V0J") -> Void {
    
    let myGroup = DispatchGroup()
    myGroup.enter()
    
    let db = Firestore.firestore()
  
    let locationsRef = db.collection("trips")
    locationsRef.getDocuments { (querySnapshot, err) in
      if let err = err {
          print("Error receiving Firestore snapshot: \(err)")
      } else {
        for document in querySnapshot!.documents {
          
          // print("\(document.documentID) => \(document.data())")
          
          
          if document.documentID == tripID {
            for (key, value) in document.data() {
              // If key not present, tripData field is not initialized
              self.switchCase(key: key, value: value)
            }
          }
        }
      }
    }
    myGroup.leave() //// When your task completes
    myGroup.notify(queue: DispatchQueue.main) {
      print("!!!!!!!!!!!!    DONE    !!!!!!!!!!!!")
    }
    
    print("***********Trip data (end of loadTripData)**************")
    print(self.tripData.trip_data)
    print("**********************************")
  }
  
  private func switchCase(key: String, value: Any) {
    switch key {
      case "user":
        self.tripData.user = value as? String
        
      case "from_location":
        self.tripData.from_location = value as? String
      
      case "to_location":
        self.tripData.to_location = value as? String
      
      case "distance":
        self.tripData.distance = value as? Int
        
      case "start_date":
        let t = value as! Timestamp
        self.tripData.start_date = t.dateValue()
        
      case "end_date":
        let t = value as! Timestamp
        self.tripData.end_date = t.dateValue()
      
      case "visible":
        self.tripData.visible = value as? Bool
      
      case "trip_data":
        let rawArray = value as! [GeoPoint]
        self.tripData.trip_data = []
        
        for point in rawArray {
          let coord = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
          self.tripData.trip_data!.append(coord)
        }
      
        print("***********Trip data (switch)**************")
        print(self.tripData.trip_data)
        print(value)
        print("**********************************")
      
      default:
        print("Invalid firebase token provided: /MapVC.swift in loadTripData()")
    }
  }
  
}

// MARK: - MapView Delegate, Polyline Renderer

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer()
    }
    
    // Polyline styles
    let polylineRenderer = MKPolylineRenderer(overlay: polyline)
    polylineRenderer.strokeColor = .systemGreen
    polylineRenderer.lineWidth = 4
    return polylineRenderer
  }
  
//  func addAnnotations() {
//      mapView.delegate = self
//      mapView.addAnnotations(places)
//
//      let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100) }
//      mapView?.addOverlays(overlays)
//
//      var locations = places.map { $0.coordinate }
//      let polyline = MKPolyline(coordinates: &locations, count: locations.count)
//      mapView?.add(polyline)
//  }
  
}


// MARK: - Mock Helper

func populateRoute(_ tripID: String = "") -> TripData {
  let tripCoords: [[Double]]
  let data = TripData()
  
  if tripID == "" {
    data.from_location = "Morewood"
    data.to_location = "Webster Hall"
    data.distance = 1
    data.start_date = Date(timeIntervalSinceReferenceDate: -123456789.0)
    data.end_date = nil
    data.visible = false
    data.user = "jTwrnfSpEiOFVmnYyFtg"
    data.trip_data = []
    //  var tripImages: [CLLocationCoordinate2D: String]
    //  var tripAnnotations: [CLLocationCoordinate2D: String]
    
    tripCoords = [
      [40.4446433, -79.9430155],
      [40.4446515, -79.943509],
      [40.4446351, -79.9441098],
      [40.4445861, -79.9449574],
      [40.4445453, -79.9457942],
      [40.4445372, -79.946674],
      [40.4450597, -79.9464809],
      [40.4455986, -79.9466311],
      [40.4462028, -79.9469315],
      [40.4467988, -79.9471461],
      [40.4472071, -79.9473714],
    ]
  } else {
    data.from_location = "x"
    data.to_location = "y"
    data.distance = 4
    data.start_date = Date(timeIntervalSinceReferenceDate: -13456789.0)
    data.end_date = Date(timeIntervalSinceReferenceDate: -13453789.0)
    data.visible = true
    data.user = "jTwrnfSpEiOFVmnYyFtg"
    data.trip_data = []
    //  var tripImages: [CLLocationCoordinate2D: String]
    //  var tripAnnotations: [CLLocationCoordinate2D: String]
    
    tripCoords = [
      [40.4446433, -79.9430155],
      [40.4446515, -79.943509],
      [40.4446351, -79.9441098],
      [40.4445861, -79.9449574],
      [40.4445453, -79.9457942],
      [40.4445372, -79.946674],
      [40.4450597, -79.9464809],
      [40.4455986, -79.9466311],
      [40.4462028, -79.9469315],
      [40.4467988, -79.9471461],
      [40.4472071, -79.9473714],
    ]
  }
  
  for arr in tripCoords {
    let coord = CLLocationCoordinate2D(latitude: arr[0], longitude: arr[1])
    data.trip_data!.append(coord)
  }
  
  print("++++++++++++++++ in populateRoute ++++++++++++")
  print(data.user)
  print(data.trip_data)
  print("++++++++++++++++++++++++++++")
  
  return data
}
