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
            VStack {
                if viewModel.searchText == "" {
                    List {
                        VStack {
                            MovieGridList(title: "Popular", movies: viewModel.popularMovies, loadMore: viewModel.getPopularMovies)
                            
                            MovieGridList(title: "Now Playing", movies: viewModel.nowPlayingMovies, loadMore: viewModel.getNowPlayingMovies)
                            
                            MovieGridList(title: "Upcoming", movies: viewModel.upcomingMovies, loadMore: viewModel.getUpcomingMovies)
                        }
                        .padding(.leading, 3)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.refreshAll()
                    }
                } else {
                    if !viewModel.searchedMovies.isEmpty {
                        List(viewModel.searchedMovies) { movie in
                            NavigationLink {
                                DetailView(movie: movie)
                            } label: {
                                HStack {
                                    AsyncImage(
                                        url: URL(string: "https://image.tmdb.org/t/p/w500/\(movie.posterPath ?? "")"),
                                        content: { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 160)
                                                .cornerRadius(8)
                                        },
                                        placeholder: {
                                            ProgressView()
                                                .frame(width: 120, height: 160)
                                        }
                                    )
                                    Text(movie.title)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                        }
                    } else {
                        Text("No Search Result")
                    }
                }
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
