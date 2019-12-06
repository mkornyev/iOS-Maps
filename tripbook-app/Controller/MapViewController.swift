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

class MapViewController: UIViewController {
  // MARK: - Passed State Vars
//  var tripID: String
//  var editView: Bool
//  var loadTrip: Bool
  private var LATENCY:Double = 2.5
  
  // MARK: - Trip Models
  
  var location: Location = Location()
  var mapView: MKMapView!
//  let floatyButtons: Floaty!
  var tripData:TripData
  
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
    
    self.mapView = MKMapView()
    frameMapView()
    self.view.addSubview(mapView)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + LATENCY) { // Shitty design but our only option
      if self.tripData.from_location == "" {
        // Show create trip annotations
        print("NO ONGOING TRIP")
        self.centerMap(onUser: true) // Sets span & region, centers map, and sets an annotation startpoint
        // self.showCreateTools() // Show new trip annotations
      } else {
        print("ONGOING TRIP")
        self.drawPolyline(self.tripData.trip_data) // Draws polyline from data, sets an annotation endpoint
        self.centerMap(onUser: false) // Center on trip
        //self.showDescripriveOverlay() // Shows map annotations 
      }
    }
    mapView.delegate = self
    showButtonTools()
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
        
        setAnnotation(coordinate: coordinate, title: "", subTitle: "You're here!")
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
}

// MARK: - Polyline Rendering

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer()
    }
    
    // Polyline styles
    let polylineRenderer = MKPolylineRenderer(overlay: polyline)
    polylineRenderer.strokeColor = .systemBlue
    polylineRenderer.lineWidth = 6
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

// MARK: - Buttons & Actions

extension MapViewController {
  struct firebaseKeys {
    static let imgFolder = "userImages" // Firebase Storage Folder
    static let imgCollection = "coll"
    static let uid = "uid"
    static let imgUrl = "url"
  }
  
  func showButtonTools() -> Void {
    let addText = UIButton(frame: CGRect(x: 75, y: 600, width: 85, height: 35))
    addText.setTitle("Add Text", for: .normal)
    addText.addTarget(self, action: #selector(addTextButtonTap), for: .touchUpInside)
    setButtonStyle(addText)

    let addImage = UIButton(frame: CGRect(x: 175, y: 600, width: 85, height: 35))
    addImage.setTitle("Add Image", for: .normal)
    addImage.addTarget(self, action: #selector(addImageButtonTap), for: .touchUpInside)
    setButtonStyle(addImage)

    let shareImage = UIButton(frame: CGRect(x: 275, y: 600, width: 85, height: 35))
    shareImage.setTitle("Share Latest Image", for: .normal)
    shareImage.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)
    setButtonStyle(shareImage)
  }
   
  func setButtonStyle(_ button: UIButton) {
    button.backgroundColor = .blue
    button.alpha = 0.85
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.darkGray, for: .highlighted)
    button.setTitleShadowColor(.systemGray, for: .normal)
    button.layer.cornerRadius = 10
    button.layer.borderWidth = 0.2
    button.layer.borderColor = UIColor.white.cgColor

    self.view.addSubview(button)
  }
 
  @objc func addTextButtonTap(sender: UIButton!) {
    print("1Button tapped")
  }
 
 @objc func addImageButtonTap(sender: UIButton!) {
  let imageVC = ImageViewController()
  imageVC.modalPresentationStyle = .overFullScreen
//  self.present(imageVC, animated: true, completion: nil)
//  self.pushViewController(imageVC, animated: true, completion: nil)
  
  self.navigationController?.pushViewController(imageVC, animated: true)
 }

 @objc func shareButtonTap(sender: UIButton!) {
   print("3Button tapped")
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

