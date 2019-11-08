//
//  MapViewWrapper.swift
//  tripbook-app
//
//  Created by Max Kornyev on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI

struct MapViewWrapper: UIViewControllerRepresentable {
  var tripID: String
  var editView: Bool
  var loadTrip: Bool
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<MapViewWrapper>) -> MapViewController {
    let mapController = MapViewController(tripID: tripID, editView: editView, loadTrip: loadTrip)
//    let mapController = MapViewController()
    return mapController
  }
  
  func updateUIViewController(_ uiViewController: MapViewController, context: UIViewControllerRepresentableContext<MapViewWrapper>) {
  }

}
