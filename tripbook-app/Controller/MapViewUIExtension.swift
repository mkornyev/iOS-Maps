//
//  ProgrammaticViewExtension.swift
//  tripbook-app
//
//  Created by Max Kornyev on 12/13/19.
//  Copyright © 2019 67442. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore
import FirebaseStorage
import Kingfisher

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
       "to_location": textField ?? ""
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
    DispatchQueue.main.asyncAfter(deadline: .now() + MapViewController.LATENCY) {
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
