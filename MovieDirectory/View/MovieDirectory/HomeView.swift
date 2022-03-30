//
//  HomeView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 29/03/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Popular")
                        .fontWeight(.bold)
                        .padding()
                        .font(.title2)
                    
                    MovieGridList(movies: viewModel.popularMovies, function: viewModel.getPopularMovies)
                    
                    Text("Now Playing")
                        .fontWeight(.bold)
                        .padding()
                        .font(.title2)
                    
                    MovieGridList(movies: viewModel.nowPlayingMovies, function: viewModel.getNowPlayingMovies)
                    
                    Text("Upcoming")
                        .fontWeight(.bold)
                        .padding()
                        .font(.title2)
                    
                    MovieGridList(movies: viewModel.upcomingMovies, function: viewModel.getUpcomingMovies)
                }
                .navigationTitle("Movie List")
                .navigationBarItems(trailing: NavigationLink {
                    WishlistView()
                } label: {
                    Text("Wishlist")
            })
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        HomeView(viewModel: viewModel)
    }
}
