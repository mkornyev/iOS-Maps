//
//  PostViewModel.swift
//  tripbook-app
//
//  Created by GF on 11/5/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI
import Combine

class PostViewModel : ObservableObject, Identifiable {
  @Published var posts : [Post] = []
  var db: Firestore!
  
  init() {
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    // [END setup]
    db = Firestore.firestore()
    db.collection("posts").getDocuments(){ (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      } else {
          for post in querySnapshot!.documents {
            print("\(post.documentID) => \(post.data())")
            if let u = post.data()["user"] as? DocumentReference {
              u.getDocument { (user, err) in
                if let user = user, user.exists {
                  let f = user.data()!["fname"]!
                  print(f)
                }
              }
            }
            let temp = Post(id: post.documentID, tagline: post.data()["tagline"] as! String, post_annotation: post.data()["post_annotation"] as! String, post_images: [""], date: post.data()["date"] as! Timestamp)
            self.posts.append(temp)
          }
      }
      
    }
  }
}
