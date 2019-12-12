//
//  CLLocationCoordinateEquatable.swift
//  tripbook-app
//
//  Created by Max Kornyev on 12/12/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Equatable {
  
  public static func ==(l: CLLocationCoordinate2D, r: CLLocationCoordinate2D) -> Bool {
      return l.latitude == r.latitude && l.longitude == r.longitude
  }
  
}
