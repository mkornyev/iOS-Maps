//
//  ProfileViewModel.swift
//  tripbook-app
//
//  Created by Matt Liu on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI
import Combine

class ProfileViewModel : ObservableObject, Identifiable {
  @Published var posts : [Post] = []
  var db: Firestore!
  private var count = 1
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
//            print("\(post.documentID) => \(post.data())")
            if let u = post.data()["user"] as? DocumentReference {
              u.getDocument { (user, err) in
                if let user = user, user.exists {
                  if user.data()!["fname"] as! String == "Jon" {
                    let f = user.data()!["fname"] as! String
                    let l = user.data()!["lname"] as! String
                    let temp = Post(id: post.documentID,  post_annotation: post.data()["post_annotation"] as! String, post_images: ["Landscape" + String(self.count)], date: post.data()["date"] as! Timestamp, username: f + " " + l, profile_pic: "Profile_pic2")
                    self.posts.append(temp)
                    self.count += 1
                  }
                }
                else {
                  print(err)
                }
              }
            }
            
          }
      }
      
    }
  }
}
