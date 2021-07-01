//
//  String+WordNumber.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation

extension String {
    func getWordNumber() -> Int {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        let words = components.filter { !$0.isEmpty }

        return words.count
    }
}
