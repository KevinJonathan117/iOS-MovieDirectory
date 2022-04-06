//
//  AppDataService.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation
import SwiftUI
import Combine

protocol DataService {
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Never>
    func getNowPlayingMovies(page: Int) -> AnyPublisher<[Movie], Never>
    func getUpcomingMovies(page: Int) -> AnyPublisher<[Movie], Never>
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Never>
    func getAllGenres(completion: @escaping ([Genre]) -> Void)
    func getMyMovies() -> [MovieItem]
    func getWishlistStatus(title: String) -> Bool
    func addMyMovies(movie: Movie) -> Bool
    func deleteMyMovies(movie: Movie) -> Bool
}

class AppDataService: DataService {
    let baseUrl = "https://api.themoviedb.org/3"
    
    func handleMovieApiCall(url: URL) -> AnyPublisher<[Movie], Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let movies = try decoder.decode(MovieList.self, from: data)
                    return movies.results
                }
                catch {
                    return []
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getPopularMovies(page: Int) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/movie/popular?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getNowPlayingMovies(page: Int) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/movie/now_playing?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getUpcomingMovies(page: Int) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/movie/upcoming?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Never> {
        guard let url = URL(string: "\(baseUrl)/search/movie?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&query=\(query)") else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getAllGenres(completion: @escaping ([Genre]) -> Void) {
        let url = URL(string: "\(baseUrl)/genre/movie/list?api_key=052510607330f148f377a72d1f5d8d26&language=en-US")!
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
