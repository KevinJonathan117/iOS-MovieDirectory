//
//  HomeViewModel.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var popularMovies = [Movie]()
        @Published var nowPlayingMovies = [Movie]()
        @Published var upcomingMovies = [Movie]()
        
        let dataService: DataService
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
        }
        
        func getPopularMovies() {
            dataService.getPopularMovies { [weak self] movies in
                self?.popularMovies = movies
            }
        }
        
        func getNowPlayingMovies() {
            dataService.getNowPlayingMovies { [weak self] movies in
                self?.nowPlayingMovies = movies
            }
        }
        
        func getUpcomingMovies() {
            dataService.getUpcomingMovies { [weak self] movies in
                self?.upcomingMovies = movies
            }
        }
    }
}
