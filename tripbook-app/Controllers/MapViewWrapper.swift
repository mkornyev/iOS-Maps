//
//  ControllerViewWrapper.swift
//  tripbook-app
//
//  Created by Max Kornyev on 11/6/19.
//  Copyright © 2019 Max Kornyev. All rights reserved.
//


import SwiftUI

//struct MapViewWrapper: View {
//  @State var tripID: String
//  @State var editView: Bool
//  @State var loadTrip: Bool
//
//  var body: some View {
//    ControllerViewWrapper(tripID: tripID, editView: editView, loadTrip: loadTrip)
////    ControllerViewWrapper()
//  }
//}

//
//struct ControllerViewWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        ControllerViewWrapper()
//    }
//}


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
