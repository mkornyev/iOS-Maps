//
//  Post.swift
//  tripbook-app
//
//  Created by GF on 11/4/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Post: Hashable, Identifiable {
  var id: String
  var post_annotation: String
  var post_images: [String]
  var date: Timestamp
  var username: String
  var profile_pic: String
  //var user_image: String
  
  //need to add reference to trip
  //like and comment count??
}
