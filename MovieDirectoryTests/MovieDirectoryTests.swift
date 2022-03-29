//
//  MovieDirectoryTests.swift
//  MovieDirectoryTests
//
//  Created by Kevin Jonathan on 28/03/22.
//

import XCTest
@testable import MovieDirectory

class MockDataService: DataService {
    func getPopularMovies(completion: @escaping ([Movie]) -> Void) {
        completion([Movie(id: 0, title: "Shawshank Redemption", posterPath: "")])
    }
}

class MovieDirectoryTests: XCTestCase {
    
    var sut: HomeView.ViewModel!

    override func setUpWithError() throws {
        sut = HomeView.ViewModel(dataService: MockDataService())
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_getPopularMovies() throws {
        XCTAssertTrue(sut.movies.isEmpty)
        sut.getPopularMovies()
        XCTAssertEqual(sut.movies.count, 1)
    }

}
