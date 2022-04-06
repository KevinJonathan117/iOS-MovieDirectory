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
        
        var cancellables: [AnyCancellable?] = []
        
        let dataService: DataService
        
        private lazy var popularMoviesPublisher: AnyPublisher<[Movie], Never> = {
            $popularPage
                .flatMap { popularPage -> AnyPublisher<[Movie], Never> in
                    self.dataService.getPopularMovies(page: popularPage)
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }()
        
        private lazy var nowPlayingMoviesPublisher: AnyPublisher<[Movie], Never> = {
            $nowPlayingPage
                .flatMap { nowPlayingPage -> AnyPublisher<[Movie], Never> in
                    self.dataService.getNowPlayingMovies(page: nowPlayingPage)
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }()
        
        private lazy var upcomingMoviesPublisher: AnyPublisher<[Movie], Never> = {
            $upcomingPage
                .flatMap { upcomingPage -> AnyPublisher<[Movie], Never> in
                    self.dataService.getUpcomingMovies(page: upcomingPage)
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }()
        
        private lazy var searchedMoviesPublisher: AnyPublisher<[Movie], Never> = {
            $searchText
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .flatMap { searchText -> AnyPublisher<[Movie], Never> in
                    self.dataService.getMoviesBySearch(query: searchText.lowercased())
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }()
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
            self.cancellables.append(popularMoviesPublisher.sink(receiveValue: { [weak self] movies in
                self?.popularMovies.append(contentsOf: movies)
            }))
            self.cancellables.append(nowPlayingMoviesPublisher.sink(receiveValue: { [weak self] movies in
                self?.nowPlayingMovies.append(contentsOf: movies)
            }))
            self.cancellables.append(upcomingMoviesPublisher.sink(receiveValue: { [weak self] movies in
                self?.upcomingMovies.append(contentsOf: movies)
            }))
            self.cancellables.append(searchedMoviesPublisher.sink(receiveValue: { [weak self] movies in
                self?.searchedMovies = movies
            }))
        }
        
        deinit {
            self.cancellables.removeAll()
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
