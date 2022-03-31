//
//  AppDataService.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation
import SwiftUI

protocol DataService {
    func getPopularMovies(completion: @escaping ([Movie]) -> Void)
    func getNowPlayingMovies(completion: @escaping ([Movie]) -> Void)
    func getUpcomingMovies(completion: @escaping ([Movie]) -> Void)
    func getAllGenres(completion: @escaping ([Genre]) -> Void)
    func getMyMovies(completion: @escaping ([MovieItem]) -> Void)
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
    
    func getNowPlayingMovies(completion: @escaping ([Movie]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=1")!
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
    
    func getUpcomingMovies(completion: @escaping ([Movie]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=1")!
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
    
    func getAllGenres(completion: @escaping ([Genre]) -> Void) {
        let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=052510607330f148f377a72d1f5d8d26&language=en-US")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let genres = try! decoder.decode(GenreList.self, from: data)
                DispatchQueue.main.async {
                    completion(genres.genres)
                }
            } else {
                print("Unexpected Error")
            }
        }
        task.resume()
    }
    
    func getMyMovies(completion: @escaping ([MovieItem]) -> Void) {
        let context = PersistenceController.shared.container.viewContext
        do {
            let movieData = try context.fetch(MovieItem.fetchRequest())
            completion(movieData)
        } catch {
            print("Cannot get all items")
        }
    }

    func addMyMovies(id: Int, title: String, posterPath: String, backdropPath: String, overview: String, releaseDate: String, genreIds: [Int]) {
        let context = PersistenceController.shared.container.viewContext
        let newItem = MovieItem(context: context)
        newItem.id = Int64(id)
        newItem.title = title
        newItem.posterPath = posterPath
        newItem.backdropPath = backdropPath
        newItem.overview = overview
        newItem.releaseDate = releaseDate
        newItem.genreIds = genreIds as NSObject

        do {
            try context.save()
        } catch {
            print("Cannot create item")
        }
    }

    func deleteMyMovies(item: MovieItem) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(item)

        do {
            try context.save()
        } catch {
            print("Cannot delete item")
        }
    }
}
