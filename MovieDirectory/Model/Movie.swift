//
//  Movie.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 28/03/22.
//

import Foundation

struct Movie: Identifiable {
    let id = UUID()
    
    var name: String = ""
    var rating: Double = 0.0
    var year: Int = 0
}
