//
//  LikeButtonView.swift
//  tripbook-app
//
//  Created by GF on 12/5/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI
import Combine


struct LikeButtonView: View {
    @State var is_liked : Bool
    @State var like_count : Int
    @State var like_count_str : String
  
    var body: some View {
      HStack(){
        Text(self.like_count_str)
          .font(.body)
          .fontWeight(.bold)
          .frame(width: 25.0)
        
          
        Button(action: {
          if self.is_liked {
            self.like_count -= 1
          } else {
            self.like_count += 1
          }
          self.like_count_str = String(self.like_count)
          self.is_liked.toggle()
        
        
        }) {
            Image(systemName: self.is_liked ? "heart.fill" : "heart")
            .resizable()
              .frame(width: CGFloat(30.0), height: CGFloat(25.0))
        }
      }
    }
}

struct LikeButtonView_Previews: PreviewProvider {
    static var previews: some View {
      LikeButtonView(is_liked: true, like_count: 2, like_count_str: "2")
    }
}
