//
//  Comment.swift
//  tripbook-app
//
//  Created by GF on 11/11/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Comment: Hashable, Identifiable {
  var id: String
  var comment: String
  var likes_count:Int
  var is_liked: Bool
  var username: String
  var profile_image: String
  var postId: String
}

