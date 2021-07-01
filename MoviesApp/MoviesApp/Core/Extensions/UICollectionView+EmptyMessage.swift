//
//  UICollectionView+EmptyMessage.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import UIKit

extension UICollectionView {
    func setEmptyMessage(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .systemGray2
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        messageLabel.sizeToFit()

        backgroundView = messageLabel
    }

    func restore() {
        backgroundView = nil
    }
}
