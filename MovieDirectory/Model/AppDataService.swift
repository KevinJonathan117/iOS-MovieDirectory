//
//  AppDataService.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation
import SwiftUI
import Combine

typealias Available = Result<[Movie], Error>

enum APIError: LocalizedError {
    case invalidRequestError(String)
    case transportError(Error)
    case invalidResponse
    case serverError(Int)
}

protocol DataService {
    func getMoviesByCategory(category: String, page: Int) -> AnyPublisher<[Movie], Error>
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Error>
    func getAllGenres(completion: @escaping ([Genre]) -> Void)
    func getMyMovies() -> [MovieItem]
    func getWishlistStatus(title: String) -> Bool
    func addMyMovies(movie: Movie) -> Bool
    func deleteMyMovies(movie: Movie) -> Bool
}

class AppDataService: DataService {
    let baseUrl = "https://api.themoviedb.org/3"
    
    func handleMovieApiCall(url: URL) -> AnyPublisher<[Movie], Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> Error in
                return APIError.transportError(error)
            }
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                if (200..<300) ~= urlResponse.statusCode {
                }
                else {
                    if (500..<600) ~= urlResponse.statusCode {
                        throw APIError.serverError(urlResponse.statusCode)
                    }
                }
                return (data, response)
            }
        
        return dataTaskPublisher
            .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), Error> in
                if case APIError.serverError = error {
                    return Just(())
                        .delay(for: 3, scheduler: DispatchQueue.global())
                        .flatMap { _ in
                            return dataTaskPublisher
                        }
                        .retry(3)
                        .eraseToAnyPublisher()
                }
                throw error
            }
            .map(\.data)
            .decode(type: MovieList.self, decoder: decoder)
            .map(\.results)
            .eraseToAnyPublisher()
    }
    
    func getMoviesByCategory(category: String, page: Int) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/movie/\(category)?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&page=\(page)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
        }
        
        return handleMovieApiCall(url: url)
    }
    
    func getMoviesBySearch(query: String) -> AnyPublisher<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/search/movie?api_key=052510607330f148f377a72d1f5d8d26&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)") else {
            return Fail(error: APIError.invalidRequestError("URL invalid"))
                .eraseToAnyPublisher()
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

extension Publisher {
    func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        self
            .map(Result.success)
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}
