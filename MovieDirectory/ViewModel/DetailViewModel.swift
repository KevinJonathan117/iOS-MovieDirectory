//
//  DetailViewModel.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 30/03/22.
//

import Foundation

extension DetailView {
    class ViewModel: ObservableObject {
        @Published var genres = [Genre]()
        @Published var isWishlist = false
        
        let dataService: DataService
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
        }
        
        func getAllGenres() {
            dataService.getAllGenres { [weak self] genres in
                self?.genres = genres
            }
        }
        
        func getWishlistStatus(title: String) {
            self.isWishlist = dataService.getWishlistStatus(title: title)
        }
        
        func addMyMovies(movie: Movie) {
            dataService.addMyMovies(movie: movie)
        }
        
        func deleteMyMovies(movie: Movie) {
            dataService.deleteMyMovies(movie: movie)
        }
        
        func getDateFromString(date: String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd"
            return dateFormatter.date(from: date)!
        }
    }
}
