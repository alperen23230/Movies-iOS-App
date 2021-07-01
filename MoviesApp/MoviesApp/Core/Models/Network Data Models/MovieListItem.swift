//
//  MovieListItem.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation

struct MovieListItem: Decodable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let identifier = UUID().uuidString

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
