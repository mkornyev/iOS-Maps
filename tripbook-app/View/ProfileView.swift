//
//  ProfileView.swift
//  tripbook-app
//
//  Created by Matt Liu on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

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

//var db: Firestore!

struct ProfileView: View {
  
  @ObservedObject private var posts = ProfileViewModel()

  let myImage = AnyView(Image("Profile_pic1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:120.0, height: 120.0)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2)))
  
  var body: some View {
    VStack(alignment: .center) {

      myImage
      Text("Jon Doe")
        .font(.title)
        .fontWeight(.bold)
      Text("Lover of travelling, documenting \n              whereever I go!")
        .font(.subheadline)


    
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
              .fontWeight(.bold)
    
          }
          .padding(.leading, 10.0)
          Image(post.post_images[0])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width:400.0, height: 400.0)
          HStack(alignment: .center, spacing: 80.0) {
            Image("Like_heart")
              .resizable()
              .frame(width: 55.0, height: 30.0)
            Divider()
            Image("Comment")
              .resizable()
              .frame(width: 50.0, height: 50.0)
          }
          .padding(.leading, 80.0)
          
          HStack(){
            Text(post.username)
              .fontWeight(.bold)
            
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
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}
