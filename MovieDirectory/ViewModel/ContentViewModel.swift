//
//  ContentViewModel.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var movies = [Movie]()
        
        let dataService: DataService
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
        }
        
        func getMovies() {
            dataService.getMovies { [weak self] movies in
                self?.movies = movies
            }
        }
    }
}
