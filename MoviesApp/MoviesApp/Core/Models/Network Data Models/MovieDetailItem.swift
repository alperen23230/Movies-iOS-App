//
//  MovieDetailItem.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation

struct MovieDetailItem: Decodable {
//    let id: Int
//    let title: String
//    let overview: String?
//    let releaseDate: String
//    let voteAverage: Double
//    let backdropPath: String?
    let imdbId: String?

    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case overview
//        case releaseDate = "release_date"
//        case voteAverage = "vote_average"
//        case backdropPath = "backdrop_path"
        case imdbId = "imdb_id"
    }
}
