//
//  ClickableMovie.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 12/04/22.
//

import SwiftUI

struct ClickableMovie: View {
    let movie: Movie
    
    var body: some View {
        VStack {
            NavigationLink {
                DetailView(movie: movie)
            } label: {
                VStack {
                    MoviePoster(path: movie.posterPath ?? "")
                    
                    Spacer()
                    
                    MovieTitleView()
                }
                
            }
            .frame(width: 120)
            
            Spacer()
        }
        .padding(.trailing)
    }
    
    @ViewBuilder private func MovieTitleView() -> some View {
        Text(movie.title)
            .multilineTextAlignment(.leading)
            .foregroundColor(.primary)
    }
}
