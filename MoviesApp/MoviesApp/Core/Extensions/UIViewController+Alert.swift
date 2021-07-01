//
//  UIViewController+Alert.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import UIKit

extension UIViewController {
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}
