//
//  CollectionViewCell.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 16.06.2021.
//

import SDWebImage
import UIKit

class SimilarMovieCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "SimilarMovieCell"

    @UsesAutoLayout
    private var movieImageView = UIImageView()
    @UsesAutoLayout
    private var movieNameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMovieImageView()
        configureNameLabel()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureMovieImageView() {
        movieImageView.layer.cornerRadius = 10
        movieImageView.clipsToBounds = true
        movieImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray

        contentView.addSubview(movieImageView)
    }

    private func configureNameLabel() {
        movieNameLabel.font = .preferredFont(forTextStyle: .body)
        movieNameLabel.textColor = .secondaryLabel
        movieNameLabel.numberOfLines = 2

        contentView.addSubview(movieNameLabel)
    }

    private func configureLayout() {
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            movieImageView.heightAnchor.constraint(equalToConstant: 80),

            movieNameLabel.topAnchor.constraint(equalTo: movieImageView.bottomAnchor),
            movieNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            movieNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(with movie: MovieListItem) {
        movieNameLabel.text = movie.title
        guard let imageURL = URL(string: "\(AppConstants.BASE_IMAGE_URL)\(movie.posterPath ?? "")") else { return }
        movieImageView.sd_setImage(with: imageURL) { [weak self] image, error, _, _ in
            self?.movieImageView.image = (error != nil) ? CustomImages.placeholderImage : image
        }
    }
}
