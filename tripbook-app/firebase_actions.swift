//
//  firebase_actions.swift
//  tripbook-app
//
//  Created by GF on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

func createPost(id: String, date: Timestamp, post_annotation: String, trip: DocumentReference, user: DocumentReference, post_images: [String]) {
  db.collection("posts").document(id).setData([
    "date": date,
    "post_annotation": post_annotation,
    "likes_count": 0,
    "comments_count": 0,
    "post_images": post_images,
    "trip": trip,
    "user": user
  ]) {
    err in
    if let err = err {
      print("Error writing document: \(err)")
    }
  }
}


