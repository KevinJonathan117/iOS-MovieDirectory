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
            List {
                VStack {
                    MovieGridList(title: "Popular", movies: viewModel.popularMovies, loadMore: viewModel.getPopularMovies)
                    
                    MovieGridList(title: "Now Playing", movies: viewModel.nowPlayingMovies, loadMore: viewModel.getNowPlayingMovies)
                    
                    MovieGridList(title: "Upcoming", movies: viewModel.upcomingMovies, loadMore: viewModel.getUpcomingMovies)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listStyle(.plain)
            .refreshable {
                //viewModel.getAllMovies()
                viewModel.refreshAll()
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Movie List")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        HomeView(viewModel: viewModel)
    }
}
