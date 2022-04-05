//
//  ContentView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Browse", systemImage: "list.dash")
                }
            
            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "list.dash")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
