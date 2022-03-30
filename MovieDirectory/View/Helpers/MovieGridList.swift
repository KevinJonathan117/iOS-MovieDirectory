//
//  MovieGridList.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 30/03/22.
//

import SwiftUI

struct MovieGridList: View {
    let movies: [Movie]
    let function: () -> Void
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(movies) { movie in
                    VStack {
                        NavigationLink {
                            DetailView()
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
                            DetailView()
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
        .onAppear(perform: function)
        .frame(height: 250)
        .padding(.leading)
    }
}

struct MovieGridList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        MovieGridList(movies: [], function: viewModel.getPopularMovies)
    }
}
