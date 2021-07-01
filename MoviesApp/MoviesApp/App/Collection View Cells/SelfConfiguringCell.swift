//
//  SelfConfiguringCell.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 16.06.2021.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with movie: MovieListItem)
}
