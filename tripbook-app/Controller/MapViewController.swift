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
  
  private var LATENCY:Double = 4
  let userRefString = "jTwrnfSpEiOFVmnYyFtg" // WILL ADD A PLIST VAL FOR THIS
  let resizedImgWidth = CGFloat(50.0)
  let resizedImgBorder = CGFloat(10.0)
  
  var counter = 0.001
  
  // MARK: - Models & Button Models
  
  var location: Location = Location()
  var mapView: MKMapView!
  var tripData:TripData
  var tripLogger: Timer?
  let loggerInterval = 5.0
//  let loggerInterval = 1.0
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + LATENCY) {
      if self.tripData.from_location == "" {
        // NEW TRIP
        self.centerMap(onUser: true) // Sets span & region, centers map, and sets an annotation startpoint
        self.showCreateTools() // Show new trip annotations
      } else {
        // ONGOING TRIP
        self.beginTripLogging()
        self.drawPolyline(self.tripData.trip_data) // Draws polyline from data, sets an annotation endpoint
        self.centerMap(onUser: false) // Center on trip
        if (self.userRefString == self.tripData.user) { self.showEditTools() }
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
              print("\n\nGOT TRIP STRING1: \(document.documentID)\n\n")
              self.tripData.loadTripData(document.documentID)
            }
          }
          else {
            print("\n\nGOT TRIP STRING2: \(document.documentID)\n\n")
            self.tripData.loadTripData(document.documentID)
          }
        }
      }
    }
  }

}

// MARK: - Polyline Rendering & Map Annotations

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
  
  // For adding Image annotations
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if !(annotation is MKPointAnnotation) {
        print("Nil")
        return nil
    }

    let annotationIdentifier = String(annotation.coordinate.latitude) + String(annotation.coordinate.longitude)
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)

    if annotationView == nil {
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        annotationView!.canShowCallout = true
    }
    else {
        annotationView!.annotation = annotation
    }
    
    if self.tripData.image_coordinates.contains(annotation.coordinate) {
      let imageIdentifier = self.tripData.image_coordinates.firstIndex(of: annotation.coordinate)!
      
      // Download Resource
      let resource = ImageResource(downloadURL: tripData.images[imageIdentifier])
      
      KingfisherManager.shared.retrieveImage(with: resource) { (result) in
        switch result {
          case .success(let value):
            let scale = self.resizedImgWidth / value.image.size.width
            let newHeight = value.image.size.height * scale
            
            let img = UIImageView(image: self.imageScaleHelper(image: value.image))
            
            let offset = -1 * (self.resizedImgWidth / 12)
            let background = UIView(frame: CGRect(x: offset, y: offset, width: self.resizedImgWidth + self.resizedImgBorder, height: newHeight + self.resizedImgBorder))
            background.backgroundColor = UIColor.systemBlue
            background.layer.cornerRadius = 7

            /*Set circle's tag to 1*/
            background.tag = 1
            /*Add the circle beneath the annotation*/
            annotationView!.insertSubview(background, at: 0)
            annotationView!.insertSubview(img, at: 1)
            
//            annotationView!.image = img
          case .failure(let err):
            print("Failed to set image: \(err)")
            annotationView!.image = UIImage(named: "TextIcon")
          default:
            annotationView!.image = UIImage(named: "TextIcon")
        }
      }
//      annotationView!.image = pinImage
    } else if self.tripData.annotation_coordinates.contains(annotation.coordinate) {
      let pinImage = UIImage(named: "MapTextIcon")
      annotationView!.image = pinImage
    } else {
      return nil
    }
    
    return annotationView
  }
  
  func imageScaleHelper(image: UIImage) -> UIImage {
    let scale = resizedImgWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: resizedImgWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: resizedImgWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    

    if let retImage = newImage {
      return retImage
    } else {
      fatalError("Couldnt resize image")
      return newImage!
    }
  }
  
  func drawPolyline(_ data: [CLLocationCoordinate2D]) -> Void {
    // REMOVE routes, replace w/TripData.trip
    let polyline = MKPolyline(coordinates: data, count: data.count)
    self.mapView.addOverlay(polyline)
    
    setAnnotation(data.first!, title: tripData.from_location, subTitle: "All roads start somewhere...")
    
    
//    if let toLoc = tripData.to_location {
//      setAnnotation(data.last!, title: toLoc, subTitle: "Is that as far as you're gonna go?")
//    } else {
//      setAnnotation(data.last!, title: "Your Location", subTitle: "Is that as far as you're gonna go?")
//    }
    
    renderTextAnnotations()
  }
  
  func renderTextAnnotations() {
    for i in 0..<tripData.annotations.count {
      let annotation = tripData.annotations[i]
      let coord = tripData.annotation_coordinates[i]

      setAnnotation(coord, title: annotation, subTitle: "")
    }
    
    // Also Image annotations
    for i in 0..<tripData.images.count {
      let coord = tripData.image_coordinates[i]

      setAnnotation(coord, title: "", subTitle: "")
    }
  }
//
//  func setImageAnnotation(_ coordinate: CLLocationCoordinate2D, title: String, subTitle: String) -> Void {
//    let annotation = MKPointAnnotation()
//    annotation.coordinate = coordinate
//    annotation.title = title
//    annotation.subtitle = subTitle
//    mapView.addAnnotation(annotation)
//  }
  
  func setAnnotation(_ coordinate: CLLocationCoordinate2D, title: String, subTitle: String) -> Void {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title
    annotation.subtitle = subTitle
    mapView.addAnnotation(annotation)
  }
  
}

// MARK: - UIButtons & Actions

extension MapViewController {
  struct firebaseKeys {
    static let imgFolder = "userImages" // Firebase Storage Folder
    static let imgCollection = "coll"
    static let uid = "uid"
    static let imgUrl = "url"
  }
  
  func showEditTools() -> Void {
    let buttonWidth = view.frame.width/3.2
    let buttonY = (self.view.frame.height*2.9)/4
    
    addText = UIButton(frame: CGRect(x: 10, y: buttonY, width: buttonWidth, height: 45))
    addText.setTitle("Add Text", for: .normal)
    addText.addTarget(self, action: #selector(addTextButtonTap), for: .touchUpInside)
    setButtonStyle(addText)
    
    addText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10).isActive = true
    addText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    addText.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true

    addImage = UIButton(frame: CGRect(x: self.view.frame.width/2 - buttonWidth/2, y: buttonY, width: buttonWidth, height: 45))
    addImage.setTitle("Add Image", for: .normal)
    addImage.addTarget(self, action: #selector(addImageButtonTap), for: .touchUpInside)
    setButtonStyle(addImage)
    
    addImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10).isActive = true
    addImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
    addImage.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true

    stopTrip = UIButton(frame: CGRect(x: (self.view.frame.width - buttonWidth - 10), y: buttonY, width: buttonWidth, height: 45))
    stopTrip.setTitle("Stop Trip", for: .normal)
    stopTrip.addTarget(self, action: #selector(stopButtonTap), for: .touchUpInside)
    setButtonStyle(stopTrip)
    
    stopTrip.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10).isActive = true
    stopTrip.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 20).isActive = true
    stopTrip.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
  }
  
  func showCreateTools() {
    let buttonWidth = view.frame.width*6/7
    let buttonY = (self.view.frame.height*2.9)/4
    
    newTrip = UIButton(frame: CGRect(x: view.frame.width/14, y: buttonY, width: buttonWidth, height: 45))
    newTrip.setTitle("New Trip", for: .normal)
    newTrip.addTarget(self, action: #selector(newTripButtonTap), for: .touchUpInside)
    setButtonStyle(newTrip)
    
    newTrip.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10).isActive = true
    newTrip.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
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
 
  @objc func newTripButtonTap(sender: UIButton!) {
    let alert = UIAlertController(title: "New Trip", message: "Enter your starting point", preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.text = "A road less travelled"
    }
    alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { [weak alert] (_) in
      let text = String(alert?.textFields![0].text! ?? "Start")
      self.tripData.from_location = text
      
      self.newTrip.removeFromSuperview()
      self.showEditTools()
      self.beginTripLogging()
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @objc func addTextButtonTap(sender: UIButton!) {
    let alert = UIAlertController(title: "Add Text", message: "Describe what you're doing!", preferredStyle: .alert)
    alert.addTextField { (textField) in
      textField.text = "Living loving life"
    }
    alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
      let text = String(alert?.textFields![0].text! ?? "Living loving life")
      
      // Update current trip
      let tripRef = Firestore.firestore().collection("trips").document(self.tripData.trip_ref)
      
      
      let lat = self.tripData.trip_data.last!.latitude
      let long = self.tripData.trip_data.last!.longitude
      
      tripRef.updateData([
         "annotations": FieldValue.arrayUnion([text]),
         "annotation_coordinates": FieldValue.arrayUnion([GeoPoint(latitude: lat, longitude: long)])
       ])
      
      self.setAnnotation(self.tripData.trip_data.last!, title: text, subTitle: "")
    }))
    present(alert, animated: true)
  }
 
 @objc func addImageButtonTap(sender: UIButton!) {
  let imageVC = ImageViewController(location: tripData.trip_data.last!, tripRefString: tripData.trip_ref)
  imageVC.modalPresentationStyle = .overFullScreen
  
  self.navigationController?.pushViewController(imageVC, animated: true)
 }

 @objc func stopButtonTap(sender: UIButton!) {
   let alert = UIAlertController(title: "Woah, traveller!", message: "Enter your final destination:", preferredStyle: .alert)
   alert.addTextField { (textField) in
       textField.text = "Somewhere far away..."
       textField.clearButtonMode = UITextField.ViewMode.whileEditing
   }
   alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
    let textField = alert?.textFields![0].text!
       
    // Stop Current Logging
    if self.tripLogger != nil {
      self.tripLogger!.invalidate()
      self.tripLogger = nil
    }
    
    // Update current trip
    let tripRef = Firestore.firestore().collection("trips").document(self.tripData.trip_ref)
    let point1 = MKMapPoint(self.tripData.trip_data.first!)
    let point2 = MKMapPoint(self.tripData.trip_data.last!)
    let dist = Int(point1.distance(to: point2));

    tripRef.updateData([
       "distance": dist,
       "end_date": Timestamp(date: Date()),
       "to_location": textField
     ])
    
    self.tripData.loadTripData(self.tripData.trip_ref) // Start Async call early
    
    self.addText.removeFromSuperview()
    self.addImage.removeFromSuperview()
    self.stopTrip.removeFromSuperview()
    
    self.renderDetailOverlay()
   }))
  
   present(alert, animated: true)
 }
  
  func renderDetailOverlay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + LATENCY) {
      let dist = String(self.tripData.distance)
      
      let distLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 60, width: self.view.frame.size.width, height: 40))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.text = dist + " meters"
        label.textColor = .black
        label.textAlignment = .center
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 0.5
        return label
      }()
      
      let diff = Calendar.current.dateComponents([.day], from: self.tripData.start_date, to: self.tripData.end_date ?? Date())
      
      let diffLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: self.view.frame.size.width, height: 40))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.text = String(format: "%02ld", diff.day!) + " days"
        label.textColor = .black
        label.textAlignment = .center
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOpacity = 0.5
        return label
      }()
      
      self.mapView.addSubview(distLabel)
      distLabel.alpha = 0
      distLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
      distLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
    
      self.mapView.addSubview(diffLabel)
      diffLabel.alpha = 0
      diffLabel.topAnchor.constraint(equalTo: distLabel.bottomAnchor, constant: 20).isActive = true
      diffLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
      
      UIView.animate(withDuration: 0.5) {
        distLabel.alpha = 1.0
        distLabel.layoutIfNeeded()
        diffLabel.alpha = 1.0
        diffLabel.layoutIfNeeded()
      }
    }
    
    let newAlert = UIAlertController(title: "Congrats on finishing your trip!", message: "You may need to restart the app to create a new one.", preferredStyle: .alert)
    newAlert.addAction(UIAlertAction(title: "Done", style: .default))
    present(newAlert, animated: true)
  }
 
}


//MARK: - Trip Logging

extension MapViewController {
  func beginTripLogging() {
    location.getCurrentLocation()
    
    // Set start coordinate
    if let coord = location.coordinate {
      tripData.trip_data.append(coord)
      setAnnotation(coord, title: "Your Location", subTitle: "All Roads Start Somewhere")
    }
    
    // Set trip struct
    tripData.user = self.userRefString
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
    if var coord = location.coordinate  {
      if tripData.trip_data.count > 1 {
        let lastCoord = self.tripData.trip_data.last!
        
        // For auto generated movement
//        let newcoord = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude + self.counter)
//        self.counter = self.counter + 0.001
//        tripData.trip_data.append(newcoord)
        
        if lastCoord.latitude != coord.latitude && lastCoord.longitude != coord.longitude { tripData.trip_data.append(coord) }
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

