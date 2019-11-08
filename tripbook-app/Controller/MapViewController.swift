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
import Floaty
//import CodableFirebase

class MapViewController: UIViewController {
  // MARK: - Passed State Vars

  var tripID: String
  var editView: Bool
  var loadTrip: Bool
  
  // MARK: - Overlay vars
  
  // MARK: - Models
  
  var location: Location = Location()
  var mapView: MKMapView!
  var tripData = TripData()
  
  // Dummy vars in place of tripData
  var from_location = ""
  var to_location: String? = nil
  var distance = 0
  var trip_data: [CLLocationCoordinate2D] = []
  var start_date = Date(timeIntervalSinceReferenceDate: -123456789.0)
  var end_date: Date? = nil
  var visible = false
  var user = ""
  
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
    fatalError("Failed to init? tripData")
  }
  
  // MARK: - Methods
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if loadTrip {
//      self.loadTripData()
      
      // The above async call takes too long (it only populates the data after viewDidLoad runs)
      // so I populate data directly:
      print("init data: \(self.tripData)")
      self.tripData = populateRoute()
      print("loaded data: \(self.tripData)")
    } else {
//      self.loadTripData(self.tripID)
      
      self.tripData = populateRoute(self.tripID)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.mapView = MKMapView()
    frameMapView()
    self.view.addSubview(mapView)
    
    let data = getRouteData()
//    self.tripData = populateRoute()
    // REMOVE populate call, replace w/tripData
//    if self.tripData.user == "" { // No trip loaded
    if false { // No trip loaded
      centerMap(onUser: true, data: data) // Sets span & region, centers map, and sets an annotation startpoint
      print("NO USER FOUND")
      // provide basic map tools
    }
//    else if populateRoute().end_date == nil { // Ongoing trip
    else if true { // Ongoing trip
      
      self.tripData.to_location = nil
      self.tripData.from_location = "Morewood"
      
      drawPolyline(data) // Draws polyline from data, sets an annotation endpoint
      centerMap(onUser: false, data: data) // Center on trip
      showButtonTools() // Show edit annotations
    }
    else { // Posted trip
      drawPolyline(data)
      centerMap(onUser: false, data: data)
      // show annotations (ie label overlay)
    }
    
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
  func centerMap(onUser: Bool, data: [CLLocationCoordinate2D]) -> Void {
    location.getCurrentLocation()
    
    if onUser {
      if let coordinate = location.coordinate {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
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
      // REMOVE & replace:
//      let data = self.tripData.trip_data!
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
  
  func showButtonTools() -> Void {
    let floaty = Floaty()
    floaty.addItem("Add Text", icon: UIImage(named: "TextIcon")!, handler: { item in
        let alert = UIAlertController(title: "Text Annotation", message: "Drag and stick this annotation onto your trip", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        floaty.close()
    })
    
    floaty.addItem("Add Image", icon: UIImage(named: "ImageIcon")!)
    
    floaty.addItem("Share Trip", icon: UIImage(named: "ArrowIcon")!, handler: { item in
      // stop trip, push to Firebase
      // show Share trip modal
      // push post to Firebase
      // showPost
      
      let alert = UIAlertController(title: "Are you sure?", message: "If you post your trip, it will have to end.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Yep, post it!", style: .default, handler: {item in
        let modalViewController = ModalViewController()
          modalViewController.modalPresentationStyle = .overFullScreen
          self.present(modalViewController, animated: true, completion: nil)
      }))
      alert.addAction(UIAlertAction(title: "Nope, wait up", style: .default, handler: { item in floaty.close() }))
      self.present(alert, animated: true, completion: nil)
    })
    
    self.view.addSubview(floaty)
  }
}

//extension MapViewController: LiquidFloatingActionButtonDataSource {
//  func numberOfCells(_ liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
//    return cells.count
//  }
//
//  func cellForIndex(_ index: Int) -> LiquidFloatingCell {
//    return cells[index]
//  }
//}
//
//extension MapViewController: LiquidFloatingActionButtonDelegate {
//  func liquidFloatingActionButton(didSelectItemAtIndex index: Int){
//    print("Button #\(index) clicked")
//  }
//}

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
        self.tripData.user = value as! String
        
      case "from_location":
        self.tripData.from_location = value as! String
      
      case "to_location":
        self.tripData.to_location = value as? String
      
      case "distance":
        self.tripData.distance = value as! Int
        
      case "start_date":
        let t = value as! Timestamp
        self.tripData.start_date = t.dateValue()
        
      case "end_date":
        let t = value as! Timestamp
        self.tripData.end_date = t.dateValue()
      
      case "visible":
        self.tripData.visible = value as! Bool
      
      case "trip_data":
        let rawArray = value as! [GeoPoint]
        self.tripData.trip_data = []
        
        for point in rawArray {
          let coord = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
          self.tripData.trip_data.append(coord)
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
  
  func drawPolyline(_ data: [CLLocationCoordinate2D]) -> Void {
    // REMOVE routes, replace w/TripData.trip
    let polyline = MKPolyline(coordinates: data, count: data.count)
    self.mapView.addOverlay(polyline)
    
    setAnnotation(coordinate: data.first!, title: tripData.from_location, subTitle: "All roads start somewhere...")
    
    if let toLoc = tripData.to_location {
      setAnnotation(coordinate: data.last!, title: toLoc, subTitle: "Is that as far as you're gonna go?")
    } else {
      setAnnotation(coordinate: data.last!, title: "Your Location", subTitle: "Is that as far as you're gonna go?")
    }
  }
  
  func setAnnotation(coordinate: CLLocationCoordinate2D, title: String, subTitle: String) -> Void {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title
    annotation.subtitle = subTitle
    mapView.addAnnotation(annotation)
  }
  
}


// MARK: - Mock Helper
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
func populateRoute(_ tripID: String = "") -> TripData {
  let tripCoords: [[Double]]
  let data = TripData()

  if tripID == "" {
    data.from_location = "Morewood"
    data.to_location = nil
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
    data.trip_data.append(coord)
  }

  print("++++++++++++++++ in populateRoute ++++++++++++")
  print(data.user)
  print(data.trip_data)
  print("++++++++++++++++++++++++++++")

  return data
}

func getRouteData() -> [CLLocationCoordinate2D] {
  let tripCoords: [[Double]]
  var retCoords: [CLLocationCoordinate2D] = []

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
  for arr in tripCoords {
    let coord = CLLocationCoordinate2D(latitude: arr[0], longitude: arr[1])
    retCoords.append(coord)
  }

  return retCoords
}


