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
    let posterPath: String?
    var backdropPath: String?
    let overview: String
    let releaseDate: String
    let genreIds: [Int]
    
    init(id: Int = 0, title: String = "", posterPath: String = "", backdropPath: String = "", overview: String = "", releaseDate: String = "", genreIds: [Int] = []) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.overview = overview
        self.releaseDate = releaseDate
        self.genreIds = genreIds
    }
    
    init(movieItem: MovieItem) {
        self.id = Int(movieItem.id)
        self.title = movieItem.title ?? ""
        self.posterPath = movieItem.posterPath ?? ""
        self.backdropPath = movieItem.backdropPath ?? ""
        self.overview = movieItem.overview ?? ""
        self.releaseDate = movieItem.releaseDate ?? ""
        self.genreIds = movieItem.genreIds as? [Int] ?? []
    }
}
