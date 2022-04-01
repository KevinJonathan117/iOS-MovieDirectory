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
        VStack {
            if viewModel.myMovies.count > 0 {
                List(viewModel.myMovies) { movie in
                    NavigationLink {
                        DetailView(movie: Movie(movieItem: movie))
                    } label: {
                        HStack {
                            AsyncImage(
                                url: URL(string: "https://image.tmdb.org/t/p/w500/\(movie.posterPath!)"),
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
                            Text(movie.title!)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        
                    }
                }
            } else {
                Text("No Wishlisted Movie")
            }
        }
        .navigationTitle("My Wishlist")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.getMyMovies()
        }
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = WishlistView.ViewModel()
        WishlistView(viewModel: viewModel)
    }
}
