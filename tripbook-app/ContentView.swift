//
//  ContentView.swift
//  tripbook-app
//
//  Created by GF on 11/2/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var selection = 0
    // Use core Data to store true for this variable if not set (in app Delegate)
    // Set data here
    @State private var firstTimeUser = true
 
    var body: some View {
      TabView(selection: $selection){
          
          // Use Navigation views to present aditional views
        NavigationView { PostCard() }
//        Text("CardView")
                .navigationBarTitle("Feed")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "list.dash")
                        Text("Feed")
                    }
                }
                .tag(0)
            Text("Friends View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "person.3")
                        Text("Friends")
                    }
                }
                .tag(1)
//            NavigationView {
//                if firstTimeUser {
//                  IntroAddTripView()
//                } else {
//                  AddTripView()
//                    .edgesIgnoringSafeArea(.bottom)
//                    .edgesIgnoringSafeArea(.top)
//                  }
//                }
          NavigationView { MapViewWrapper(tripID: "ignored when loadData == true", editView: true, loadTrip: true) }
                .edgesIgnoringSafeArea(.top)
                .navigationBarTitle("Your Trip") //** Doesnt work
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Trip")
                    }
                }
                .tag(2)
          NavigationView { ProfileView() }
              .font(.title)
              .tabItem {
                  VStack {
                      Image(systemName: "person")
                      Text("My Trips")
                  }
              }
            .tag(3)
            Text("Settings View")
              .font(.title)
              .tabItem {
                  VStack {
                      Image(systemName: "slider.horizontal.3")
                      Text("Settings")
                  }
              }
            .tag(4)
        }.font(.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

