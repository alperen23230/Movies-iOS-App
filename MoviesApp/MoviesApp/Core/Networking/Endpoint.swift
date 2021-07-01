//
//  Endpoint.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/" + path
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }

        return url
    }
}

extension Endpoint {
    static func getNowPlaying() -> Self {
        Endpoint(
            path: "/3/movie/now_playing"
        )
    }

    static func getUpcoming(page: Int) -> Self {
        Endpoint(
            path: "/3/movie/upcoming",
            queryItems: [URLQueryItem(name: "page", value: String(page))]
        )
    }

    static func searchMovie(searchQuery: String) -> Self {
        Endpoint(
            path: "/3/search/movie",
            queryItems: [URLQueryItem(name: "query", value: searchQuery)]
        )
    }

    static func getMovieDetail(id: Int) -> Self {
        let stringId = String(id)
        return Endpoint(
            path: "/3/movie/\(stringId)"
        )
    }

    static func getSimilarMovies(id: Int) -> Self {
        let stringId = String(id)
        return Endpoint(
            path: "/3/movie/\(stringId)/similar"
        )
    }
}
