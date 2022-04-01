//
//  MovieDirectoryTests.swift
//  MovieDirectoryTests
//
//  Created by Kevin Jonathan on 28/03/22.
//

import XCTest
@testable import MovieDirectory

class MockDataService: DataService {
    func getMyMovies(completion: @escaping ([Movie]) -> Void) {
        completion([Movie(id: 0, title: "Shawshank", posterPath: "", backdropPath: "", overview: "", releaseDate: "", genreIds: [])])
    }
    
    func getPopularMovies(completion: @escaping ([Movie]) -> Void) {
        completion([Movie(id: 0, title: "Shawshank", posterPath: "", backdropPath: "", overview: "", releaseDate: "", genreIds: [])])
    }
    
    func getNowPlayingMovies(completion: @escaping ([Movie]) -> Void) {
        completion([Movie(id: 0, title: "Shawshank", posterPath: "", backdropPath: "", overview: "", releaseDate: "", genreIds: []), Movie(id: 1, title: "Batman", posterPath: "", backdropPath: "", overview: "", releaseDate: "", genreIds: [])])
    }
    
    func getUpcomingMovies(completion: @escaping ([Movie]) -> Void) {
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
        homeSut.getPopularMovies()
        XCTAssertEqual(homeSut.popularMovies.count, 1)
    }
    
    func test_getNowPlayingMovies() throws {
        XCTAssertTrue(homeSut.nowPlayingMovies.isEmpty)
        homeSut.getNowPlayingMovies()
        XCTAssertEqual(homeSut.nowPlayingMovies.count, 2)
    }
    
    func test_getUpcomingMovies() throws {
        XCTAssertTrue(homeSut.upcomingMovies.isEmpty)
        homeSut.getUpcomingMovies()
        XCTAssertEqual(homeSut.upcomingMovies.count, 1)
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
    }
}
