//
//  DetailView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import SwiftUI

struct DetailView: View {
    @StateObject var viewModel: ViewModel
    @State private var showingAlert = false
    
    init(movie: Movie, viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        viewModel.movie = movie
    }
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500/\(viewModel.movie.backdropPath ?? "")")) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.size.width)
                    } else if phase.error != nil {
                        Spacer()
                        
                        EmptyView()
                            .frame(width: UIScreen.main.bounds.size.width, height: 200)
                        
                        Spacer()
                    } else {
                        Spacer()
                        
                        ProgressView()
                            .frame(width: UIScreen.main.bounds.size.width, height: 200)
                        
                        Spacer()
                    }
                }
                
                MoviePoster(path: viewModel.movie.posterPath ?? "")
                .offset(y: -100)
                .padding(.bottom, -100)
                
                Group {
                    Text(viewModel.movie.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("Released on: \(viewModel.getDateFromString(date: viewModel.movie.releaseDate).formatted(date: .long, time: .omitted))")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    
                    HStack {
                        ForEach(viewModel.genres) { genre in
                            if viewModel.movie.genreIds.contains(genre.id) {
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
                    
                    Text(viewModel.movie.overview)
                }
                .padding([.top, .leading, .trailing])
                
            }
            .navigationTitle("Detail")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                if viewModel.isWishlist {
                    print(viewModel.deleteMyMovies(movie: viewModel.movie))
                    viewModel.getWishlistStatus(title: viewModel.movie.title)
                    
                } else {
                    print(viewModel.addMyMovies(movie: viewModel.movie))
                    viewModel.getWishlistStatus(title: viewModel.movie.title)
                }
                showingAlert = true
            } label: {
                Label("Toggle Wishlist", systemImage: viewModel.isWishlist ? "star.fill" : "star")
                    .labelStyle(.iconOnly)
            }).alert(viewModel.isWishlist ? "Added to Wishlist" : "Deleted from Wishlist", isPresented: $showingAlert) {
                Button("Got it!", role: .cancel) { }
            }
            .onAppear {
                viewModel.getWishlistStatus(title: viewModel.movie.title)
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
