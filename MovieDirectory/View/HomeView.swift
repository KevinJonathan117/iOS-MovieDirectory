//
//  HomeView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 29/03/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Popular")
                    .fontWeight(.bold)
                    .padding()
                    .font(.title2)
                
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.movies) { movie in
                            VStack {
                                AsyncImage(
                                    url: URL(string: "https://image.tmdb.org/t/p/w500/\(movie.posterPath)"),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 160)
                                    },
                                    placeholder: {
                                        Spacer()
                                        
                                        ProgressView()
                                            .frame(width: 120, height: 160)
                                        
                                        Spacer()
                                    }
                                )
                                
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
                .onAppear(perform: viewModel.getPopularMovies)
                .frame(height: 250)
                .padding(.leading)
                
                Spacer()
            }
            .navigationTitle("Movie List")
            .navigationBarItems(trailing: NavigationLink {
                WishlistView()
            } label: {
                Text("Wishlist")
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeView.ViewModel()
        HomeView(viewModel: viewModel)
    }
}
