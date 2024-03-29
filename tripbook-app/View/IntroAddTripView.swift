//
//  IntroAddTripView.swift
//  tripbook-app


import SwiftUI

struct IntroAddTripView: View {
    var body: some View {
      VStack {
        Spacer()
        HStack{
          Text("Add Trip").font(.largeTitle)
          Spacer()
        }.padding(20)
        Text("You can use this tab to create your first Trip.")
          .padding(20)
        Text("We will generate your trip map using location coordinates that are saved only during an ongoing trip. Allow location access below:").padding(15)
//          .overlay(
//            RoundedRectangle(cornerRadius: 25)
//                .stroke(Color.blue, lineWidth: 1)
//        )
          .padding([.leading, .trailing], 30)
        // Passing tripData without loading 
        NavigationLink(destination: MapViewWrapper(data: TripData())) {
          Text("Allow Access")
            .padding(.top, 20)
            .font(.title)
            .foregroundColor(Color.green)
          }
        }
    }
}

struct IntroAddTripView_Previews: PreviewProvider {
    static var previews: some View {
        IntroAddTripView()
    }
}
