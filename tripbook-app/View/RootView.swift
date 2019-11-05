//
//  ContentView.swift
//  iOS Maps
//
//  Created by Max Kornyev on 11/2/19.
//  Copyright © 2019 Max Kornyev. All rights reserved.
//

import SwiftUI
import MapKit

struct RootView: View {
    @State private var selection = 0
    @State private var firstTimeUser = true
 
    var body: some View {
        TabView(selection: $selection){
          
          // Use Navigation views to present aditional views
          NavigationView {
            Text("Feed View")
            .navigationBarTitle("Feed") }
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
            NavigationView {
                if firstTimeUser {
                  IntroAddTripView()
                } else {
                  AddTripView()
                    .edgesIgnoringSafeArea(.bottom)
                    .edgesIgnoringSafeArea(.top)
                    .navigationBarTitle("Your Trip")
                  }
                }
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Trip")
                    }
                }
                .tag(2)
            Text("My Trips View")
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
        RootView()
    }
}

