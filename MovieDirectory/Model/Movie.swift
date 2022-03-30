//
//  Movie.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation

struct MovieList: Decodable {
    let results: [Movie]
}

struct Movie: Identifiable, Decodable {
    let id: Int
    let title: String
    let posterPath: String
    let backdropPath: String
    let overview: String
    let releaseDate: String
    let genreIds: [Int]
}
