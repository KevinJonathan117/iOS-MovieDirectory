//
//  DetailViewModel.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 30/03/22.
//

import Foundation

extension DetailView {
    class ViewModel: ObservableObject {
        @Published var genres = [Genre]()
        
        let dataService: DataService
        
        init(dataService: DataService = AppDataService()) {
            self.dataService = dataService
        }
        
        func getAllGenres() {
            dataService.getAllGenres { [weak self] genres in
                self?.genres = genres
            }
        }
        
        func getDateFromString(date: String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd"
            return dateFormatter.date(from: date)!
        }
    }
}
