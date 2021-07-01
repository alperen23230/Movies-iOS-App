//
//  UICollectionView+Loading.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Foundation
import UIKit

extension UICollectionView {
    func setLoading() {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
    }
}
