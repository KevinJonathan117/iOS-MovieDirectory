//
//  ContentView.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List(viewModel.movies) { movie in
            Text(movie.name)
        }
        .onAppear(perform: viewModel.getMovies)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let movie = Movie(name: "Shawshank", rating: 9.2, year: 2017)
        let viewModel = ContentView.ViewModel()
        viewModel.movies = [movie]
        
        return ContentView(viewModel: viewModel)
    }
}
