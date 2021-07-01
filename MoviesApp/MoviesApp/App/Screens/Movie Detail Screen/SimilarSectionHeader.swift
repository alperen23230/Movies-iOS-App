//
//  SimilarSectionHeader.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 19.06.2021.
//

import UIKit

class SimilarSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "SimilarSectionHeader"

    @UsesAutoLayout
    private var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTitleLabel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureTitleLabel() {
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = "Similar Movies"

        addSubview(titleLabel)
    }
}
