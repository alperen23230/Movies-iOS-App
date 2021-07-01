//
//  Constants.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation
import UIKit

enum SFSymbols {
    static let rightArrow = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .regular, scale: .default))
    static let star = UIImage(systemName: "star.fill")
}

enum CustomImages {
    static let imdbLogo = UIImage(named: "imdb-logo")
    static let placeholderImage = UIImage(named: "placeholder")
}

enum ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
}

enum AppConstants {
    static let BEARER_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyMzdlMDE1MjQ0MmQzZDBjMmZjNDMxMjg4NTIyNjdhNSIsInN1YiI6IjYwMmZmNjkyYmIwNzBkMDA0MGI3OTk5NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M_zaRujYoz5CDT9-XRDyZGZE5vqTa4KFt4uYrbw9WjU"

    static let BASE_IMAGE_URL = "https://image.tmdb.org/t/p/w500"
    static let IMDB_BASE_URL = "https://www.imdb.com/title"
}
