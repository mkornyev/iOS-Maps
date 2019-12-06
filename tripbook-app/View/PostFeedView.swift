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
    NavigationView{
     VStack{
        List(posts.posts){ (post: Post) in
          VStack(alignment: .leading) {
            HStack(){
              Image(post.profile_pic)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:50.0, height: 50.0)
                .clipShape(Circle())
                .shadow(radius: 10)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                
              Text(post.username)
                .font(.body)
                .fontWeight(.bold)
      
            }
            .padding(.leading, 10.0)
            Image(post.post_images[0])
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width:400.0, height: 400.0)
            HStack(alignment: .center, spacing: 80.0) {
              LikeButtonView(is_liked: post.is_liked, like_count: post.likes_count, like_count_str: String(post.likes_count))
    
              
              Divider()
              NavigationLink(destination: CommentsView(comments: [Comment(id:"1",comment: "Cool trip! Looked Fun.Cool trip! hope you had a good time this is random text  ",likes_count: 0,is_liked: false,username: "Jon Doe",profile_image: "Profile_pic1",  postId: "1"),
                                      Comment(id:"1",comment: "Cool trip!  ",likes_count: 0,is_liked: false,username: "Jon Doe",profile_image: "Profile_pic1",  postId: "1"),
                            
              ], postId: "1")){
                Image("Comment")
                .resizable()
                .frame(width: 50.0, height: 50.0)
              }.navigationBarTitle(Text("Feed"),displayMode: .inline)
              
            }
            .padding(.leading, 80.0)
            
    //        Text(String(post.likes_count)+" Likes")
    //            .fontWeight(.bold)
    //          .font(.body)
    //          .padding(.leading, 25.0)
    //          .padding(.bottom, 10.0)
            
            HStack(){
              Text(post.username)
                .fontWeight(.bold)
                .font(.body)
              Text(post.post_annotation)
                .font(.headline)
                .fontWeight(.regular)
              
            }.padding(.leading, 25.0)
          
          }
          .padding(.horizontal, -20)
          .padding([.top,.bottom], 10)
          
        }
      }
    }
   // }.navigationBarTitle(Text("Feed"),displayMode: .inline)
  }
 
}

struct PostCard_Previews: PreviewProvider {
  static var previews: some View {
    PostCard()
  }
}
