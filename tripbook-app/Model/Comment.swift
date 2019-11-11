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
  var likes_count:Int = 0
  var user: DocumentReference
  var post: DocumentReference
}

