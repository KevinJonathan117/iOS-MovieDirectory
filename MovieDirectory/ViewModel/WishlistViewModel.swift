//
//  WishlistViewModel.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 30/03/22.
//

import Foundation

extension WishlistView {
    class ViewModel: ObservableObject {
        @Published var myMovies = [MovieItem]()
        
        let dataService: DataService
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
        }
        
        func getMyMovies() {
            dataService.getMyMovies { [weak self] movies in
                self?.myMovies = movies
            }
        }
    }
}
