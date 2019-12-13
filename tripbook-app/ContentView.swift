//
//  ContentView.swift
//  tripbook-app
//
//  Created by GF on 11/2/19.
//  Copyright © 2019 67442. All rights reserved.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct ContentView: View {
    @State private var selection = 0
    // Use core Data to store true for this variable if not set (in app Delegate)
    // Set data here
    @State private var firstTimeUser:Bool = false
    @State private var tripData:TripData = TripData()
  
//    init() {
//        UINavigationBar.appearance().backgroundColor = .systemBlue
//    }
 
    var body: some View {
      TabView(selection: $selection){
          
              // Use Navigation views to present aditional views
            NavigationView { PostCard().navigationBarTitle("Feed")  }
                    .font(.title)
                    .tabItem {
                        VStack {
                            Image(systemName: "list.dash")
                            Text("Feed")
                        }
                    }
                .tag(0)
            NavigationView { FriendsView().navigationBarTitle("Friends")  }
                    .font(.title)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.3")
                            Text("Friends")
                        }
                    }
                .tag(1)
            NavigationView {
                if firstTimeUser { IntroAddTripView().navigationBarTitle("My TripBook")  }
                else { MapViewWrapper(data: tripData)
//                  .onAppear() { self.loadTrip() }
                  .navigationBarTitle("Your Trip") }
                }
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Trip")
                    }
                }
                .tag(2)
          NavigationView { ProfileView().navigationBarTitle("Profile")  }
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
