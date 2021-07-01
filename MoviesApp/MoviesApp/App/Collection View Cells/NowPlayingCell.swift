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
    
    private let imageViewGradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
        configureNameLabel()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageViewGradient.frame = imageView.bounds
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
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
        addGradientToImageView()
        
        NSLayoutConstraint.activate(imageView.constraintsForAnchoringTo(boundsOf: contentView))
    }
    
    private func addGradientToImageView() {
        imageViewGradient.frame = imageView.bounds
        let startColor = UIColor.black.withAlphaComponent(0).cgColor
        let endColor = UIColor.black.withAlphaComponent(0.8).cgColor
        imageViewGradient.startPoint = CGPoint(x: 0.5, y: 0)
        imageViewGradient.endPoint = CGPoint(x: 0.5, y: 1)
        imageViewGradient.colors = [startColor, endColor]
        imageView.layer.addSublayer(imageViewGradient)
    }
    
    func configure(with movie: MovieListItem) {
        nameLabel.text = movie.title
        guard let imageURL = URL(string: "\(AppConstants.BASE_IMAGE_URL)\(movie.backdropPath ?? "")") else { return }
        imageView.sd_setImage(with: imageURL) { [weak self] image, error, _, _ in
            self?.imageView.image = (error != nil) ? CustomImages.placeholderImage : image
        }
    }
}
