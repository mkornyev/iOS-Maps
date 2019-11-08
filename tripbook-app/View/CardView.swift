//
//  CardView.swift
//  tripbook-app
//
//  Created by Matt Liu on 11/8/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI

struct CardView: View {
  
    let images = ["Landscape1", "Landscape2"]
  
    var category: String
    var heading: String
    var author: String
      
    var body: some View {
      
      List(images, id: \.self) { i in
        
      
        VStack {
          Image(i)
                .resizable()
                .aspectRatio(contentMode: .fit)
              
            HStack {
                VStack(alignment: .leading) {
                  Text(self.category)
                        .font(.headline)
                        .foregroundColor(.secondary)
                  Text(self.heading)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                  Text(self.author.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .layoutPriority(100)

                Spacer()
            }
            .padding()
        }
        .navigationBarTitle(Text("Featured"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top, .horizontal])
    }
  }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(category: "SwiftUI", heading: "Drawing a Border with Rounded Corners", author: "Simon Ng")

    }
}

