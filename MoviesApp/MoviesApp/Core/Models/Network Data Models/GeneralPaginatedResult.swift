//
//  GeneralPaginatedResult.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation

struct GeneralPaginatedResult<T: Decodable>: Decodable {
    var results: [T]
    let totalPagesCount: Int

    enum CodingKeys: String, CodingKey {
        case results
        case totalPagesCount = "total_pages"
    }
}
