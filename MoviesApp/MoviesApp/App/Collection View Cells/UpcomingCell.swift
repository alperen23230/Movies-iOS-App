//
//  UpcomingCollectionViewCell.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 16.06.2021.
//

import SDWebImage
import UIKit

class UpcomingCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "UpcomingCell"

    @UsesAutoLayout
    private var imageView = UIImageView()
    @UsesAutoLayout
    private var rightArrowImageView = UIImageView(image: SFSymbols.rightArrow)
    @UsesAutoLayout
    private var titleLabel = UILabel()
    @UsesAutoLayout
    private var overviewLabel = UILabel()
    @UsesAutoLayout
    private var releaseDateLabel = UILabel()
    @UsesAutoLayout
    private var seperator = UIView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabels()
        configureImageViews()
        configureSeperator()
        configureViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSeperator() {
        seperator.backgroundColor = .quaternaryLabel

        contentView.addSubview(seperator)
    }

    private func configureLabels() {
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.adjustsFontSizeToFitWidth = true

        overviewLabel.font = .preferredFont(forTextStyle: .subheadline)
        overviewLabel.textColor = .secondaryLabel
        overviewLabel.numberOfLines = 3

        releaseDateLabel.font = .preferredFont(forTextStyle: .footnote)
        releaseDateLabel.textColor = .secondaryLabel

        contentView.addSubview(titleLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(releaseDateLabel)
    }

    private func configureImageViews() {
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray

        rightArrowImageView.tintColor = .secondaryLabel

        contentView.addSubview(imageView)
        contentView.addSubview(rightArrowImageView)
    }

    private func configureViews() {
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),

            rightArrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightArrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 12),
            rightArrowImageView.heightAnchor.constraint(equalToConstant: 20),
            rightArrowImageView.widthAnchor.constraint(equalToConstant: 15),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: rightArrowImageView.leadingAnchor),

            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            overviewLabel.trailingAnchor.constraint(equalTo: rightArrowImageView.leadingAnchor),

            releaseDateLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 12),
            releaseDateLabel.trailingAnchor.constraint(equalTo: rightArrowImageView.leadingAnchor, constant: -12),

            seperator.heightAnchor.constraint(equalToConstant: 1),
            seperator.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            seperator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(with movie: MovieListItem) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        releaseDateLabel.text = movie.releaseDate ?? ""
        guard let imageURL = URL(string: "\(AppConstants.BASE_IMAGE_URL)\(movie.posterPath ?? "")") else { return }
        imageView.sd_setImage(with: imageURL) { [weak self] image, error, _, _ in
            self?.imageView.image = (error != nil) ? CustomImages.placeholderImage : image
        }
    }
}
