//
//  MovieDirectoryTests.swift
//  MovieDirectoryTests
//
//  Created by Kevin Jonathan on 28/03/22.
//

import XCTest
import Combine
@testable import MovieDirectory

class MockDataService: DataService {
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        print("Popular: \(page)")
        guard page > 0 else {
            return Fail(error: APIError.serverError(500))
                .delay(for: 3, scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
        return Just([Movie(), Movie(), Movie()])
            .delay(for: 3, scheduler: DispatchQueue.global())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
    func getNowPlayingMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        guard page > 0 else {
            return Fail(error: APIError.serverError(500))
                .delay(for: 3, scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
        return Just([Movie(), Movie()])
            .delay(for: 3, scheduler: DispatchQueue.global())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getUpcomingMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        guard page > 0 else {
            return Fail(error: APIError.serverError(500))
                .delay(for: 3, scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
        return Just([Movie(), Movie(), Movie(), Movie()])
            .delay(for: 3, scheduler: DispatchQueue.global())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Error> {
        guard query == "Harry Potter" else {
            return Fail(error: APIError.invalidRequestError("Error"))
                .delay(for: 3, scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
        return Just([Movie(), Movie(), Movie(), Movie(), Movie()])
            .delay(for: 3, scheduler: DispatchQueue.global())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getMyMovies(completion: @escaping ([Movie]) -> Void) {
        completion([Movie(id: 0, title: "Shawshank", posterPath: "", backdropPath: "", overview: "", releaseDate: "", genreIds: [])])
    }
    
    func getAllGenres(completion: @escaping ([Genre]) -> Void) {
        completion([Genre(id: 0, name: "Action"), Genre(id: 1, name: "Comedy"), Genre(id: 2, name: "Fantasy")])
    }
    
    func getMyMovies() -> [MovieItem] {
        let context = PersistenceController.shared.container.viewContext
        do {
            let movieData = try context.fetch(MovieItem.fetchRequest())
            return movieData
        } catch {
            print("Cannot get all items")
            return []
        }
    }
    
    func getWishlistStatus(title: String) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        do {
            let movieData = try context.fetch(MovieItem.fetchRequest())
            let isWishlist = movieData.contains(where: { $0.title == title })
            return isWishlist
        } catch {
            print("Cannot get all items before getting status")
            return false
        }
    }
    
    func addMyMovies(movie: Movie) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        let newItem = MovieItem(context: context)
        newItem.id = Int64(movie.id)
        newItem.title = movie.title
        newItem.posterPath = movie.posterPath
        newItem.backdropPath = movie.backdropPath
        newItem.overview = movie.overview
        newItem.releaseDate = movie.releaseDate
        newItem.genreIds = movie.genreIds as [NSNumber]
        
        do {
            try context.save()
            return true
        } catch {
            print("Cannot add item")
            return false
        }
    }
    
    func deleteMyMovies(movie: Movie) -> Bool {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            let movieData: MovieItem = getMyMovies().filter({ $0.title == movie.title })[0]
            context.delete(movieData)
            try context.save()
            return true
        } catch {
            print("Cannot delete item")
            return false
        }
    }
}

class MovieDirectoryTests: XCTestCase {
    
    var homeSut: HomeView.ViewModel!
    var detailSut: DetailView.ViewModel!
    var wishlistSut: WishlistView.ViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        homeSut = HomeView.ViewModel(dataService: MockDataService())
        detailSut = DetailView.ViewModel(dataService: MockDataService())
        wishlistSut = WishlistView.ViewModel(dataService: MockDataService())
    }
    
    override func tearDownWithError() throws {
        homeSut = nil
        detailSut = nil
        wishlistSut = nil
    }
    
    func test_getPopularMovies() throws {
        XCTAssertTrue(homeSut.popularMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "noError1")
        let successExpect = expectation(description: "results1")
        homeSut.$popularPage
            .removeDuplicates()
            .flatMap { popularPage -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getPopularMovies(page: popularPage)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.popularMovies.removeAll()
                XCTAssertEqual(errorMsg, "")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.popularMovies.count, 0)
                self.homeSut.popularMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.popularMovies.count, 3)
                successExpect.fulfill()
            }
            .store(in: &cancellables)
        
        self.homeSut.popularPage += 1
        
        wait(for: [errorExpect, successExpect], timeout: 10)
    }
    
    func test_getPopularMoviesFail() throws {
        XCTAssertTrue(homeSut.popularMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "hasError1")
        homeSut.$popularPage
            .removeDuplicates()
            .flatMap { popularPage -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getPopularMovies(page: popularPage)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.popularMovies.removeAll()
                XCTAssertEqual(errorMsg, "Server Error")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.popularMovies.count, 0)
                self.homeSut.popularMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.popularMovies.count, 0)
            }
            .store(in: &cancellables)
        
        self.homeSut.popularPage = 0
        
        wait(for: [errorExpect], timeout: 10)
    }
    
    func test_getNowPlayingMovies() throws {
        XCTAssertTrue(homeSut.nowPlayingMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "noError2")
        let successExpect = expectation(description: "results2")
        self.homeSut.nowPlayingMovies.removeAll()
        homeSut.$nowPlayingPage
            .removeDuplicates()
            .flatMap { nowPlayingPage -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getNowPlayingMovies(page: nowPlayingPage)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.nowPlayingMovies.removeAll()
                XCTAssertEqual(errorMsg, "")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.nowPlayingMovies.count, 0)
                self.homeSut.nowPlayingMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.nowPlayingMovies.count, 2)
                successExpect.fulfill()
            }
            .store(in: &cancellables)
        
        self.homeSut.nowPlayingPage += 1
        
        wait(for: [errorExpect, successExpect], timeout: 10)
    }
    
    func test_getNowPlayingMoviesFail() throws {
        XCTAssertTrue(homeSut.nowPlayingMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "hasError2")
        self.homeSut.nowPlayingMovies.removeAll()
        homeSut.$nowPlayingPage
            .removeDuplicates()
            .flatMap { nowPlayingPage -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getNowPlayingMovies(page: nowPlayingPage)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.nowPlayingMovies.removeAll()
                XCTAssertEqual(errorMsg, "Server Error")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.nowPlayingMovies.count, 0)
                self.homeSut.nowPlayingMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.nowPlayingMovies.count, 0)
            }
            .store(in: &cancellables)
        
        self.homeSut.nowPlayingPage = 0
        
        wait(for: [errorExpect], timeout: 10)
    }
    
    func test_getUpcomingMovies() throws {
        XCTAssertTrue(homeSut.upcomingMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "noError3")
        let successExpect = expectation(description: "results3")
        self.homeSut.upcomingMovies.removeAll()
        homeSut.$upcomingPage
            .removeDuplicates()
            .flatMap { upcomingPage -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getUpcomingMovies(page: upcomingPage)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.upcomingMovies.removeAll()
                XCTAssertEqual(errorMsg, "")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.upcomingMovies.count, 0)
                self.homeSut.upcomingMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.upcomingMovies.count, 4)
                successExpect.fulfill()
            }
            .store(in: &cancellables)
        
        self.homeSut.upcomingPage += 1
        
        wait(for: [errorExpect, successExpect], timeout: 10)
    }
    
    func test_getUpcomingMoviesFail() throws {
        XCTAssertTrue(homeSut.upcomingMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "hasError3")
        self.homeSut.upcomingMovies.removeAll()
        homeSut.$upcomingPage
            .removeDuplicates()
            .flatMap { upcomingPage -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getNowPlayingMovies(page: upcomingPage)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.upcomingMovies.removeAll()
                XCTAssertEqual(errorMsg, "Server Error")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.upcomingMovies.count, 0)
                self.homeSut.upcomingMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.upcomingMovies.count, 0)
            }
            .store(in: &cancellables)
        
        self.homeSut.upcomingPage = 0
        
        wait(for: [errorExpect], timeout: 10)
    }
    
    func test_getSearchedMovies() throws {
        XCTAssertTrue(homeSut.searchedMovies.isEmpty)
        var errorMsg: String = ""
        
        //let errorExpect = expectation(description: "noError4")
        //let successExpect = expectation(description: "results4")
        self.homeSut.searchedMovies.removeAll()
        homeSut.$searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { searchText -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getMoviesBySearch(query: searchText)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("Error") = error {
                        errorMsg = "No Result"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.searchedMovies.removeAll()
                XCTAssertEqual(errorMsg, "")
                //errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.searchedMovies.count, 0)
                self.homeSut.searchedMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.searchedMovies.count, 5)
                //successExpect.fulfill()
            }
            .store(in: &cancellables)
        
        self.homeSut.searchText = "Harry Potter"
        
        //wait(for: [errorExpect, successExpect], timeout: 10)
    }
    
    func test_getSearchedMoviesFail() throws {
        XCTAssertTrue(homeSut.searchedMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "hasError4")
        self.homeSut.searchedMovies.removeAll()
        homeSut.$searchText
            .removeDuplicates()
            .flatMap { searchText -> AnyPublisher<Available, Never> in
                self.homeSut.dataService.getMoviesBySearch(query: searchText)
                    .asResult()
            }
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
            .map { result -> [Movie] in
                if case .failure(let error) = result {
                    if case APIError.transportError(_) = error {
                        errorMsg = "Transport Error"
                        return []
                    } else if case APIError.serverError(statusCode: _) = error {
                        errorMsg = "Server Error"
                        return []
                    } else if case APIError.invalidRequestError("URL invalid") = error {
                        errorMsg = "Invalid URL"
                        return []
                    } else {
                        errorMsg = "Error Occured"
                        return []
                    }
                }
                if case .success(let movies) = result {
                    return movies
                }
                return []
            }
            .sink {
                self.homeSut.searchedMovies.removeAll()
                XCTAssertEqual(errorMsg, "Error Occured")
                errorExpect.fulfill()
                XCTAssertEqual(self.homeSut.searchedMovies.count, 0)
                self.homeSut.searchedMovies.append(contentsOf: $0)
                XCTAssertEqual(self.homeSut.searchedMovies.count, 0)
            }
            .store(in: &cancellables)
        
        self.homeSut.searchText = "dfihsdiofhas"
        
        wait(for: [errorExpect], timeout: 10)
    }
    
    func test_getAllGenres() throws {
        XCTAssertTrue(detailSut.genres.isEmpty)
        detailSut.getAllGenres()
        XCTAssertEqual(detailSut.genres.count, 3)
    }
    
    func test_coreData() throws {
        wishlistSut.myMovies = []
        XCTAssertTrue(wishlistSut.myMovies.isEmpty)
        print(detailSut.addMyMovies(movie: Movie(title: "Shawshank")))
        wishlistSut.getMyMovies()
        XCTAssertEqual(wishlistSut.myMovies.count, 1)
        print(detailSut.deleteMyMovies(movie: Movie(title: "Shawshank")))
        wishlistSut.getMyMovies()
        XCTAssertTrue(wishlistSut.myMovies.isEmpty)
    }
}
