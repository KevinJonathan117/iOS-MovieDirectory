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
            VStack {
                List(viewModel.movies) { movie in
                    NavigationLink {
                        DetailView()
                    } label: {
                        Text(movie.name)
                    }
                }
                .onAppear(perform: viewModel.getMovies)
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
