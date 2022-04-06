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
    
    func handleMovieApiCall(url: URL) -> AnyPublisher<[Movie], Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let movies = try decoder.decode(MovieList.self, from: data)
                    return movies.results
                }
                catch {
                    print(error)
                    return []
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/movie/popular?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getNowPlayingMovies(page: Int) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/movie/now_playing?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getUpcomingMovies(page: Int) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/movie/upcoming?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/search/movie?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)") else {
            return Just([]).eraseToAnyPublisher()
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
    
    private var cancellables: [AnyCancellable?] = []
    
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
        
        lazy var popularMoviesPublisher: AnyPublisher<[Movie], Never> = {
            homeSut.$popularPage
                .flatMap { popularPage -> AnyPublisher<[Movie], Never> in
                    self.homeSut.dataService.getPopularMovies(page: popularPage)
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }()
        
        cancellables.append(popularMoviesPublisher.sink(receiveValue: { [weak self] movies in
            self?.homeSut.popularMovies.append(contentsOf: movies)
        }))
        
        homeSut.popularPage = 2
        XCTAssertEqual(detailSut.genres.count, 0)
        
//        wait(for: [expectation], timeout: 1)
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
