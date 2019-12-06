//
//  CommentView.swift
//  tripbook-app
//
//  Created by GF on 12/5/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI

struct CommentView: View {
  var profile_image: String
  var username: String
  var comment: String
  var is_liked: Bool
  var likes_count: Int

  var body: some View {
    
    VStack(alignment: .leading){
      HStack(){
        Image(self.profile_image)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width:50.0, height: 50.0)
        .clipShape(Circle())
        .shadow(radius: 10)
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        Text(self.username)
          .fontWeight(.bold)
        
      }
      .frame(width: 385.0, alignment: .leading)
     
      
      Text(self.comment) .padding(20.0).lineLimit(nil).multilineTextAlignment( .leading)
      HStack{
      LikeButtonView(is_liked: self.is_liked, like_count: self.likes_count, like_count_str: String(self.likes_count))
      }
        .frame(width: 385.0, alignment: .trailing)
    
    }
   
    
  
    .frame( alignment: .trailing)
    
  
   
  }
  
}

struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    VStack{
      CommentView(profile_image: "Profile_pic1", username: "Jon Doe", comment: "Cool trip! Looked Fun.Cool trip! hope you had a good time this is random text  ", is_liked: false, likes_count: 0)
    
    CommentView(profile_image: "Profile_pic1", username: "Jon Doe", comment: "Cool trip! Looked Fun.", is_liked: false, likes_count: 0)
    }
    
  }
}
