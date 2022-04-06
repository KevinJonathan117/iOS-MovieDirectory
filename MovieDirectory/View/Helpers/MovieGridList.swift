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
                                AsyncImage(
                                    url: URL(string: "https://image.tmdb.org/t/p/w500/\(movie.posterPath)"),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 160)
                                            .cornerRadius(8)
                                    },
                                    placeholder: {
                                        Spacer()
                                        
                                        ProgressView()
                                            .frame(width: 120, height: 160)
                                        
                                        Spacer()
                                    }
                                )
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
                        AsyncImage(
                            url: URL(string: "https://image.tmdb.org/t/p/w500/"),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 160)
                                    .cornerRadius(8)
                            },
                            placeholder: {
                                Spacer()
                                
                                ProgressView()
                                    .frame(width: 120, height: 160)
                                
                                Spacer()
                            }
                        )
                        
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
