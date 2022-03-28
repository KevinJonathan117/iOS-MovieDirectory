//
//  AppDataService.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation

protocol DataService {
    func getMovies(completion: @escaping ([Movie]) -> Void)
}

class AppDataService: DataService {
    func getMovies(completion: @escaping ([Movie]) -> Void) {
        DispatchQueue.main.async {
            completion([
                Movie(name: "Batman", rating: 9.1, year: 2015),
                Movie(name: "Shawshank Redemption", rating: 9.3, year: 2017)
            ])
        }
    }
}
