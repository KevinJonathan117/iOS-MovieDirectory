//
//  HomeViewModel.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation
import Combine

extension HomeView {
    class ViewModel: ObservableObject {
        @Published var popularMovies = [Movie]()
        @Published var nowPlayingMovies = [Movie]()
        @Published var upcomingMovies = [Movie]()
        @Published var searchedMovies = [Movie]()
        
        @Published var searchText: String = ""
        @Published var popularPage: Int = 1
        @Published var nowPlayingPage: Int = 1
        @Published var upcomingPage: Int = 1
        
        private var cancellables = Set<AnyCancellable>()
        
        let dataService: DataService
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
            initObserver()
        }
        
        deinit {
            self.cancellables.removeAll()
        }
        
        func initObserver() {
            $popularPage
                .removeDuplicates()
                .flatMap { popularPage -> AnyPublisher<[Movie], Never> in
                    self.dataService.getPopularMovies(page: popularPage)
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] movies in
                    self?.popularMovies.append(contentsOf: movies)
                }
                .store(in: &cancellables)
            
            $nowPlayingPage
                .removeDuplicates()
                .flatMap { nowPlayingPage -> AnyPublisher<[Movie], Never> in
                    self.dataService.getNowPlayingMovies(page: nowPlayingPage)
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] movies in
                    self?.nowPlayingMovies.append(contentsOf: movies)
                }
                .store(in: &cancellables)
            
            $upcomingPage
                .removeDuplicates()
                .flatMap { upcomingPage -> AnyPublisher<[Movie], Never> in
                    self.dataService.getUpcomingMovies(page: upcomingPage)
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] movies in
                    self?.upcomingMovies.append(contentsOf: movies)
                }
                .store(in: &cancellables)
            
            $searchText
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .flatMap { searchText -> AnyPublisher<[Movie], Never> in
                    self.dataService.getMoviesBySearch(query: searchText.lowercased())
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] movies in
                    self?.searchedMovies = movies
                }
                .store(in: &cancellables)
        }
        
        func refreshAll() {
            popularMovies.removeAll()
            nowPlayingMovies.removeAll()
            upcomingMovies.removeAll()
            popularPage = 1
            nowPlayingPage = 1
            upcomingPage = 1
        }
        
        func getPopularMovies() {
            popularPage += 1
        }
        
        func getNowPlayingMovies() {
            nowPlayingPage += 1
        }
        
        func getUpcomingMovies() {
            upcomingPage += 1
        }
    }
}
