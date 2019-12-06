//
//  CommentsView.swift
//  tripbook-app
//
//  Created by GF on 12/5/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct CommentsView: View {
  @State var comments: [Comment]
  @State var postId: String
  @State private var comment_text = ""
  var body: some View {
    //NavigationView{
      VStack {
          List (comments) { comment in
                CommentView(profile_image: comment.profile_image, username: comment.username, comment: comment.comment, is_liked: comment.is_liked, likes_count: comment.likes_count)
              }
          HStack{
            TextField("Write a comment", text: $comment_text).padding(.all).frame(height: 20.0).lineLimit(nil)
          Button(action: {
              
            self.post_comment()
            }){
              Text("Post")
            
            }
          }.padding(.all, 5.0).overlay(
              RoundedRectangle(cornerRadius: 20)
                  .stroke(Color.gray, lineWidth: 3)
          )
      }.navigationBarTitle(Text("Comments"),displayMode: .inline)
   // }
    
  }
  
  private func post_comment(){
    let new_id = self.postId+String(self.comments.count+1)
    let new_comment = Comment(id: new_id, comment: self.comment_text, likes_count: 0, is_liked: false, username: "Jon Doe", profile_image: "Profile_pic1", postId: self.postId)
    self.comments.append(new_comment)
    
//  db.collection("comments").document(new_id).setData([
//      "comment": self.comment_text,
//        "likes_count": 0,
//        "post": self.postId,
//        "user": "jTwrnfSpEiOFVmnYyFtg"
//    ]) { err in
//        if let err = err {
//            print("Error writing document: \(err)")
//        } else {
//            print("Document successfully written!")
//        }
  //  }
  }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
      CommentsView(comments: [Comment(id:"1",comment: "Cool trip! Looked Fun.Cool trip! hope you had a good time this is random text  ",likes_count: 0,is_liked: false,username: "Jon Doe",profile_image: "Profile_pic1",  postId: "1"),
                              Comment(id:"1",comment: "Cool trip!  ",likes_count: 0,is_liked: false,username: "Jon Doe",profile_image: "Profile_pic1",  postId: "1"),
                    
      ], postId: "1")
    }
}
