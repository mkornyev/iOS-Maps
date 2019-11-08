//
//  User.swift
//  tripbook-app
//
//  Created by GF on 11/7/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User : Hashable, Identifiable {
  var id: String
  var bio: String
  var email: String
  var fname: String
  var lname: String
  var miles_travelled: Float
  var friends_count: Int
}
