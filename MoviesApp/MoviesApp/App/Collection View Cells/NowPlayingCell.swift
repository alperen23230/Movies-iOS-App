//
//  NowPlayingCell.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 16.06.2021.
//

import SDWebImage
import UIKit

class NowPlayingCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "NowPlayingCell"

    @UsesAutoLayout
    private var imageView = UIImageView()
    @UsesAutoLayout
    private var nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
        configureNameLabel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureNameLabel() {
        nameLabel.font = .preferredFont(forTextStyle: .title2)
        nameLabel.textColor = .white

        imageView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 170),
            nameLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
        ])
    }

    private func configureImageView() {
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray

        contentView.addSubview(imageView)

        NSLayoutConstraint.activate(imageView.constraintsForAnchoringTo(boundsOf: contentView))
    }

    func configure(with movie: MovieListItem) {
        nameLabel.text = movie.title
        guard let imageURL = URL(string: "\(AppConstants.BASE_IMAGE_URL)\(movie.backdropPath ?? "")") else { return }
        imageView.sd_setImage(with: imageURL) { [weak self] image, error, _, _ in
            self?.imageView.image = (error != nil) ? CustomImages.placeholderImage : image
        }
    }
}
