//
//  AppDataService.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation

protocol DataService {
    func getPopularMovies(completion: @escaping ([Movie]) -> Void)
}

class AppDataService: DataService {
    func getPopularMovies(completion: @escaping ([Movie]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let movies = try! decoder.decode(MovieList.self, from: data)
                DispatchQueue.main.async {
                    completion(movies.results)
                }
            } else {
                print("Unexpected Error")
            }
        }
        task.resume()
    }
}
