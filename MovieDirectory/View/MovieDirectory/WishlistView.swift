//
//  WishlistView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import SwiftUI

struct WishlistView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.myMovies.isEmpty {
                    List(viewModel.myMovies) { movie in
                        NavigationLink {
                            DetailView(movie: Movie(movieItem: movie))
                        } label: {
                            HStack {
                                MoviePoster(path: movie.posterPath ?? "")
                                
                                Text(movie.title ?? "Default")
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                        }
                    }
                } else {
                    Text("No Wishlisted Movie")
                }
            }
            
            .onAppear {
                viewModel.getMyMovies()
            }
            .navigationTitle("My Wishlist")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = WishlistView.ViewModel()
        WishlistView(viewModel: viewModel)
    }
}
