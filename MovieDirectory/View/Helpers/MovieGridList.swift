//
//  MovieGridList.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 30/03/22.
//

import SwiftUI

struct MovieGridList: View {
    let title: String
    let movies: [Movie]
    let loadMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .font(.title2)
                .padding(.vertical)
            ScrollView (.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(movies) { movie in
                        VStack {
                            NavigationLink {
                                DetailView(movie: movie)
                            } label: {
                                MoviePoster(path: movie.posterPath ?? "")
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                DetailView(movie: movie)
                            } label: {
                                Text(movie.title)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 120)
                            
                            Spacer()
                        }
                        .padding(.trailing)
                    }
                    VStack {
                        Spacer()
                        
                        ProgressView()
                        
                        Spacer()
                        
                        Text("")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 120)
                    .onAppear(perform: loadMore)
                }
                .padding(.trailing)
            }
        }
        .frame(height: 300)
        .padding(.leading)
    }
}

struct MovieGridList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        MovieGridList(title: "Popular", movies: viewModel.popularMovies, loadMore: viewModel.getPopularMovies)
    }
}
