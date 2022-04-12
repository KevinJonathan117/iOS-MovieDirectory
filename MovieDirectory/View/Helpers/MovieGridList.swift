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
            TitleView()
            ScrollView (.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(movies) { movie in
                        ClickableMovie(movie: movie)
                    }
                    MovieLoaderView()
                }
                .padding(.trailing)
            }
        }
        .frame(height: 300)
        .padding(.leading)
    }
    
    @ViewBuilder private func TitleView() -> some View {
        Text(title)
            .fontWeight(.bold)
            .font(.title2)
            .padding(.vertical)
    }
    
    @ViewBuilder private func MovieLoaderView() -> some View {
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
}

struct MovieGridList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        MovieGridList(title: "Popular", movies: viewModel.popularMovies, loadMore: viewModel.getPopularMovies)
    }
}
