//
//  PostCard.swift
//  tripbook-app
//
//  Created by GF on 11/2/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import Combine

var db: Firestore!

struct PostCard: View {
  
  @ObservedObject private var posts = PostViewModel()
   
  var body: some View {
    
    List(posts.posts){ (post: Post) in
      VStack(alignment: .leading) {
        
        Image("Landscape1")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width:400.0, height: 400.0)
        HStack() {
          Image("Like_heart")
            .resizable()
            .frame(width: 55.0, height: 30.0)
          Image("Comment")
            .resizable()
            .frame(width: 50.0, height: 50.0)
        }
        .padding(.leading, 5.0)
      
        Text(post.post_annotation)
          .font(.headline)
          .fontWeight(.regular)
          .padding(.leading, 20.0)
          
      
      }
      .padding(.horizontal, -20)

      
    }
    
      
  }
}

struct PostCard_Previews: PreviewProvider {
  static var previews: some View {
    PostCard()
  }
}
