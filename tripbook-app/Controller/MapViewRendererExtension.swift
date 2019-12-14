//
//  MapRendererExtension.swift
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

// MARK: - Polyline Rendering & Map Annotations

extension MapViewController: MKMapViewDelegate {
  
  // Overlay rendering
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
        return MKOverlayRenderer()
    }
    
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
          case .failure(let err):
            print("Failed to set image: \(err)")
            annotationView!.image = UIImage(named: "TextIcon")
          default:
            annotationView!.image = UIImage(named: "TextIcon")
        }
      }
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
    }
  }
  
  func drawPolyline(_ data: [CLLocationCoordinate2D]) -> Void {
    let polyline = MKPolyline(coordinates: data, count: data.count)
    self.mapView.addOverlay(polyline)
    
    setAnnotation(data.first!, title: tripData.from_location, subTitle: "All roads start somewhere...")
    
    
//    if let toLoc = tripData.to_location {
//      setAnnotation(data.last!, title: toLoc, subTitle: "Is that as far as you're gonna go?")
//    } else {
//      setAnnotation(data.last!, title: "Your Location", subTitle: "Is that as far as you're gonna go?")
//    }
    
    renderAnnotations()
  }
  
  func renderAnnotations() {
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
  
  func setAnnotation(_ coordinate: CLLocationCoordinate2D, title: String, subTitle: String) -> Void {
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotation.title = title
    annotation.subtitle = subTitle
    mapView.addAnnotation(annotation)
  }
  
}
