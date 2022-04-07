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
        
        @Published var showErrorAlert = false
        @Published var alertDialog = ""
        @Published var searchDialog = ""
        
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
                .flatMap { popularPage -> AnyPublisher<Available, Never> in
                    self.dataService.getPopularMovies(page: popularPage)
                        .asResult()
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .map { result -> [Movie] in
                    if case .failure(let error) = result {
                        self.showErrorAlert = true
                        if case APIError.transportError(_) = error {
                            self.alertDialog = "Transport Error"
                            return []
                        } else if case APIError.serverError(statusCode: _) = error {
                            self.alertDialog = "Server Error"
                                return []
                        } else if case APIError.invalidRequestError("URL invalid") = error {
                            self.alertDialog = "Invalid URL"
                            return []
                        } else {
                            self.alertDialog = "Error Occured"
                            return []
                        }
                    }
                    if case .success(let movies) = result {
                        return movies
                    }
                    return []
                }
                .sink { movies in
                    self.popularMovies.append(contentsOf: movies)
                }
                .store(in: &cancellables)
            
            $nowPlayingPage
                .removeDuplicates()
                .flatMap { nowPlayingPage -> AnyPublisher<Available, Never> in
                    self.dataService.getNowPlayingMovies(page: nowPlayingPage)
                        .asResult()
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .map { result -> [Movie] in
                    if case .failure(let error) = result {
                        self.showErrorAlert = true
                        if case APIError.transportError(_) = error {
                            self.alertDialog = "Transport Error"
                            return []
                        } else if case APIError.serverError(statusCode: _) = error {
                            self.alertDialog = "Server Error"
                                return []
                        } else if case APIError.invalidRequestError("URL invalid") = error {
                            self.alertDialog = "Invalid URL"
                            return []
                        } else {
                            self.alertDialog = "Error Occured"
                            return []
                        }
                    }
                    if case .success(let movies) = result {
                        return movies
                    }
                    return []
                }
                .sink { movies in
                    self.nowPlayingMovies.append(contentsOf: movies)
                }
                .store(in: &cancellables)
            
            $upcomingPage
                .removeDuplicates()
                .flatMap { upcomingPage -> AnyPublisher<Available, Never> in
                    self.dataService.getUpcomingMovies(page: upcomingPage)
                        .asResult()
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .map { result -> [Movie] in
                    if case .failure(let error) = result {
                        self.showErrorAlert = true
                        if case APIError.transportError(_) = error {
                            self.alertDialog = "Transport Error"
                            return []
                        } else if case APIError.serverError(statusCode: _) = error {
                            self.alertDialog = "Server Error"
                                return []
                        } else if case APIError.invalidRequestError("URL invalid") = error {
                            self.alertDialog = "Invalid URL"
                            return []
                        } else {
                            self.alertDialog = "Error Occured"
                            return []
                        }
                    }
                    if case .success(let movies) = result {
                        return movies
                    }
                    return []
                }
                .sink { movies in
                    self.upcomingMovies.append(contentsOf: movies)
                }
                .store(in: &cancellables)
            
            $searchText
                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .removeDuplicates()
                .flatMap { searchText -> AnyPublisher<Available, Never> in
                    self.dataService.getMoviesBySearch(query: searchText)
                        .asResult()
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .map { result -> [Movie] in
                    if case .failure(let error) = result {
                        if case APIError.transportError(_) = error {
                            self.searchDialog = "Transport Error"
                            return []
                        } else if case APIError.serverError(statusCode: _) = error {
                            self.searchDialog = "Server Error"
                            return []
                        } else if case APIError.invalidRequestError("URL invalid") = error {
                            self.searchDialog = "Invalid URL"
                            return []
                        } else {
                            self.searchDialog = "No Search Result"
                            return []
                        }
                    }
                    if case .success(let movies) = result {
                        return movies
                    }
                    return []
                }
                .assign(to: &$searchedMovies)
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
