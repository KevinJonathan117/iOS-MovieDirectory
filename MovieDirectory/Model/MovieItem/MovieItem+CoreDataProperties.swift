//
//  MovieItem+CoreDataProperties.swift
//  MovieDirectory
//
//  Created by Kevin Jonathan on 31/03/22.
//
//

import Foundation
import CoreData


extension MovieItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieItem> {
        return NSFetchRequest<MovieItem>(entityName: "MovieItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var id: Int64
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var genreIds: [NSNumber]?

}

extension MovieItem : Identifiable {

}
