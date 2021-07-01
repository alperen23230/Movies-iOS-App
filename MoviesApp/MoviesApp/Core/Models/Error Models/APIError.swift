//
//  APIError.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation

struct APIError: Decodable, Error {
    let statusMessage: String
    let statusCode: Int

    enum CodingKeys: String, CodingKey {
        case statusMessage = "status_message"
        case statusCode = "status_code"
    }
}
