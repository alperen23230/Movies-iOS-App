//
//  SearchItemCell.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 16.06.2021.
//

import UIKit

class SearchItemCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "SearchItemCell"

    @UsesAutoLayout
    private var rightArrowImageView = UIImageView(image: SFSymbols.rightArrow)
    @UsesAutoLayout
    private var titleLabel = UILabel()
    @UsesAutoLayout
    private var seperator = UIView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureLabel()
        configureSeperator()
        configureViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSeperator() {
        seperator.backgroundColor = .quaternaryLabel

        contentView.addSubview(seperator)
    }

    private func configureLabel() {
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        contentView.addSubview(titleLabel)
    }

    private func configureViews() {
        rightArrowImageView.tintColor = .secondaryLabel

        contentView.addSubview(rightArrowImageView)

        NSLayoutConstraint.activate([
            rightArrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rightArrowImageView.heightAnchor.constraint(equalToConstant: 20),
            rightArrowImageView.widthAnchor.constraint(equalToConstant: 15),
            rightArrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: rightArrowImageView.leadingAnchor, constant: -12),

            seperator.heightAnchor.constraint(equalToConstant: 1),
            seperator.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            seperator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),

        ])
    }

    func configure(with movie: MovieListItem) {
        titleLabel.text = movie.title
    }
}
