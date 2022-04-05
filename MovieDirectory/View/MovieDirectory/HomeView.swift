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
                    MovieGridList(title: "Popular", movies: viewModel.popularMovies, function: viewModel.getPopularMovies)
                    
                    MovieGridList(title: "Now Playing", movies: viewModel.nowPlayingMovies, function: viewModel.getNowPlayingMovies)
                    
                    MovieGridList(title: "Upcoming", movies: viewModel.upcomingMovies, function: viewModel.getUpcomingMovies)
                }
                .navigationTitle("Movie List")
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
