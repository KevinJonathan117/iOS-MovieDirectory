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
    let baseUrl = "https://api.themoviedb.org/3"
    
    func handleMovieApiCall(url: URL) -> AnyPublisher<[Movie], Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> Error in
                return APIError.transportError(error)
            }
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200..<300) ~= urlResponse.statusCode {
                }
                else {
                    if (500..<600) ~= urlResponse.statusCode {
                        throw APIError.serverError(urlResponse.statusCode)
                    }
                }
                return (data, response)
            }
        
        return dataTaskPublisher
            .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), Error> in
                if case APIError.serverError = error {
                    return Just(())
                        .delay(for: 3, scheduler: DispatchQueue.global())
                        .flatMap { _ in
                            return dataTaskPublisher
                        }
                        .retry(3)
                        .eraseToAnyPublisher()
                }
                throw error
            }
            .map(\.data)
            .decode(type: MovieList.self, decoder: decoder)
            .map(\.results)
            .eraseToAnyPublisher()
    }
    
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/movie/popular?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getNowPlayingMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/movie/now_playing?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getUpcomingMovies(page: Int) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/movie/upcoming?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/search/movie?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
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
        
        let errorExpect = expectation(description: "noError")
        let successExpect = expectation(description: "results")
        self.homeSut.popularMovies.removeAll()
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
                XCTAssertEqual(self.homeSut.popularMovies.count, 20)
                successExpect.fulfill()
            }
            .store(in: &cancellables)
        
        self.homeSut.popularPage += 1
        
        wait(for: [errorExpect, successExpect], timeout: 10)
    }
    
    func test_getPopularMoviesFail() throws {
        XCTAssertTrue(homeSut.popularMovies.isEmpty)
        var errorMsg: String = ""
        
        let errorExpect = expectation(description: "hasError")
        self.homeSut.popularMovies.removeAll()
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
                XCTAssertEqual(errorMsg, "Error Occured")
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
        
    }
    
    func test_getUpcomingMovies() throws {
        
    }
    
    func test_getSearchedMovies() throws {
        
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
