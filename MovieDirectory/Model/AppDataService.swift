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
    func getMyMovies() -> [MovieItem]
    func getWishlistStatus(title: String) -> Bool
    func addMyMovies(movie: Movie) -> Bool
    func deleteMyMovies(movie: Movie) -> Bool
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
        let movieData: MovieItem = getMyMovies().filter({ $0.title == movie.title })[0]
        context.delete(movieData)
        
        do {
            try context.save()
            return true
        } catch {
            print("Cannot delete item")
            return false
        }
    }
}
