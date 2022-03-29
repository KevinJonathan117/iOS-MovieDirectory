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
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let dataString = String(data: data, encoding: .utf8)
                print(dataString ?? "")
                DispatchQueue.main.async {
                    completion([
                        Movie(name: "Batman", rating: 9.1, year: 2015),
                        Movie(name: "Shawshank Redemption", rating: 9.3, year: 2017)
                    ])
                }
            } else {
                print("Unexpected Error")
            }
        }
        task.resume()
    }
}
