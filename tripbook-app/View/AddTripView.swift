//
//  AddTripView.swift
//  iOSMaps
//
//  Created by Max Kornyev on 11/2/19.
//  Copyright © 2019 Max Kornyev. All rights reserved.
//

import SwiftUI
import MapKit

struct AddTripView: UIViewRepresentable {
  
  var location: Location = Location()
  // Current trip should be set by api call
//  var trip: Trip? = nil
  
  func makeUIView(context: UIViewRepresentableContext<AddTripView>) -> MKMapView {
    MKMapView(frame: .zero)
  }

  func updateUIView(_ view: MKMapView, context: Context) {
    view.showsUserLocation = true

    // Grab current location
    if let coordinate = location.getCurrentLocationCoordinate() {
      // **Set zoom level for ongoing trips
      let span = MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
      
      let region = MKCoordinateRegion(center: coordinate, span: span)
      view.setRegion(region, animated: true)
    } else {
      // push new VC onto map
    }
  }
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
      AddTripView().edgesIgnoringSafeArea(.bottom).edgesIgnoringSafeArea(.top)
    }
}
