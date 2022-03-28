//
//  MovieDirectoryTests.swift
//  MovieDirectoryTests
//
//  Created by Kevin Jonathan on 28/03/22.
//

import XCTest
@testable import MovieDirectory

class MockDataService: DataService {
    func getMovies(completion: @escaping ([Movie]) -> Void) {
        completion([Movie(name: "Shawshank", rating: 9.2, year: 2017)])
    }
}

class MovieDirectoryTests: XCTestCase {
    
    var sut: ContentView.ViewModel!

    override func setUpWithError() throws {
        sut = ContentView.ViewModel(dataService: MockDataService())
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_getMovies() throws {
        XCTAssertTrue(sut.movies.isEmpty)
        sut.getMovies()
        XCTAssertEqual(sut.movies.count, 1)
    }

}
