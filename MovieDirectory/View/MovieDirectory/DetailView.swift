//
//  DetailView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import SwiftUI

struct DetailView: View {
    @StateObject var viewModel: ViewModel
    var movie: Movie
    
    init(movie: Movie, viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.movie = movie
    }
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(
                    url: URL(string: "https://image.tmdb.org/t/p/w500/\(movie.backdropPath!)"),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.size.width)
                    },
                    placeholder: {
                        Spacer()
                        
                        ProgressView()
                            .frame(width: UIScreen.main.bounds.size.width, height: 200)
                        
                        Spacer()
                    }
                )
                
                AsyncImage(
                    url: URL(string: "https://image.tmdb.org/t/p/w500/\(movie.posterPath)"),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 160)
                            .cornerRadius(8)
                            .shadow(radius: 7)
                    },
                    placeholder: {
                        Spacer()
                        
                        EmptyView()
                            .frame(width: 120, height: 160)
                        
                        Spacer()
                    }
                )
                .offset(y: -100)
                .padding(.bottom, -100)
                
                Group {
                    Text(movie.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Released on: \(viewModel.getDateFromString(date: movie.releaseDate).formatted(date: .long, time: .omitted))")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    HStack {
                        ForEach(viewModel.genres) { genre in
                            if movie.genreIds.contains(genre.id) {
                                Text(genre.name)
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4.0)
                                    .background(.black)
                                    .cornerRadius(8)
                            }
                        }
                    }.onAppear(perform: viewModel.getAllGenres)
                    
                    Text(movie.overview)
                }
                .padding([.top, .leading, .trailing])
                
            }
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                if viewModel.isWishlist {
                    viewModel.deleteMyMovies(movie: movie)
                    viewModel.getWishlistStatus(title: movie.title)
                } else {
                    viewModel.addMyMovies(movie: movie)
                    viewModel.getWishlistStatus(title: movie.title)
                }
                print("Button Tapped")
            } label: {
                Label("Toggle Wishlist", systemImage: viewModel.isWishlist ? "text.badge.minus" : "text.badge.plus")
                    .labelStyle(.iconOnly)
            })
            .onAppear {
                viewModel.getWishlistStatus(title: movie.title)
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let movie = Movie()
        DetailView(movie: movie)
    }
}
