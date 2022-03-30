//
//  Genre.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 30/03/22.
//

import Foundation

struct GenreList: Decodable {
    let genres: [Genre]
}

struct Genre: Identifiable, Decodable {
    let id: Int
    let name: String
}
