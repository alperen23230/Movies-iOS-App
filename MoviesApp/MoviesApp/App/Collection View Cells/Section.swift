//
//  Section.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 16.06.2021.
//

import Foundation

enum SectionType {
    case nowPlaying, upcoming, search
}

struct ListSection: Hashable {
    let type: SectionType
    let title: String
    var items: [MovieListItem]

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

    static func == (lhs: ListSection, rhs: ListSection) -> Bool {
        lhs.type == rhs.type
    }
}

enum SimilarSection {
    case main
}
