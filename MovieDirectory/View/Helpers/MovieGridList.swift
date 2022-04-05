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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .padding()
                .font(.title2)
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
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
                    
                }
            }
            .frame(height: 250)
        .padding(.leading)
        }
    }
}

struct MovieGridList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        MovieGridList(title: "Popular", movies: viewModel.popularMovies)
    }
}
