//
//  MovieDetailViewController.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 19.06.2021.
//

import Combine
import Resolver
import SafariServices
import SDWebImage
import UIKit

class MovieDetailViewController: UIViewController {
    // From initializer
    var currentMovie: MovieListItem
    var currentMovieImbdId: String

    // UI Variables
    @UsesAutoLayout
    private var scrollView = UIScrollView()
    @UsesAutoLayout
    private var contentView = UIView()
    @UsesAutoLayout
    private var movieImageView = UIImageView()
    @UsesAutoLayout
    private var movieContentView = UIView()
    @UsesAutoLayout
    private var titleLabel = UILabel()
    @UsesAutoLayout
    private var overviewLabel = UILabel()
    @UsesAutoLayout
    private var starLabel = UILabel()
    @UsesAutoLayout
    private var starImageView = UIImageView(image: SFSymbols.star)
    @UsesAutoLayout
    private var releaseDateLabel = UILabel()
    @UsesAutoLayout
    private var imdbImageView = UIImageView(image: CustomImages.imdbLogo)
    @UsesAutoLayout
    var seperator = UIView(frame: .zero)
    var infoStackView: UIStackView!

    // Injected models
    @LazyInjected private var movieDetailViewModel: MovieDetailViewModel
    @LazyInjected private var movieDetailManager: MovieDetailManager

    // CollectionView and Data Sources
    private var similarMoviesCollectionView: UICollectionView!
    private var similarMoviesDataSource: UICollectionViewDiffableDataSource<SimilarSection, MovieListItem>!

    init(movie: MovieListItem, imdbId: String) {
        currentMovie = movie
        currentMovieImbdId = imdbId
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        setupScrollView()
        setupMovieImageView()
        setupMovieContentView()
        setupLabels()
        setupMovieInfoStackView()
        setupSimilarMoviesCollectionView()
        configureSimilarMoviesDataSource()
        configureAutoLayout()
        setViewModelListeners()
        movieDetailViewModel.getSimilarMovies(with: currentMovie.id)
    }

    private func configureNavBar() {
        title = currentMovie.title
        navigationItem.largeTitleDisplayMode = .never
    }
}

// MARK: - View Model Listeners

extension MovieDetailViewController {
    private func setViewModelListeners() {
        Publishers.CombineLatest(movieDetailViewModel.similarMovies, movieDetailViewModel.isLoadingSimilarMovies).sink { [weak self] movieList, isLoading in
            if isLoading {
                self?.similarMoviesCollectionView.setLoading()
            } else {
                if movieList.isEmpty {
                    self?.similarMoviesCollectionView.setEmptyMessage(message: "There's no similar movies :(")
                } else {
                    self?.similarMoviesCollectionView.restore()
                    self?.createSnapshot(from: movieList)
                }
            }
        }
        .store(in: &movieDetailViewModel.cancellables)

        movieDetailManager.currentImdbId.sink { [weak self] currentId in
            guard let willSendMovie = self?.movieDetailManager.willSendMovieDetail else { return }
            self?.navigationController?.pushViewController(MovieDetailViewController(movie: willSendMovie, imdbId: currentId), animated: true)
        }
        .store(in: &movieDetailManager.cancellables)
    }
}

// MARK: - UI Setup

extension MovieDetailViewController {
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func setupMovieImageView() {
        movieImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        guard let imageURL = URL(string: "\(AppConstants.BASE_IMAGE_URL)\(currentMovie.posterPath ?? "")") else { return }
        movieImageView.sd_setImage(with: imageURL) { [weak self] image, error, _, _ in
            self?.movieImageView.image = (error != nil) ? CustomImages.placeholderImage : image
        }
        movieImageView.contentMode = .scaleToFill

        contentView.addSubview(movieImageView)
    }

    @objc private func imdbImageTapped() {
        if currentMovieImbdId == "" {
            showSimpleAlert(title: "Error", message: "There is no movie in IMDB !")
            return
        }
        guard let url = URL(string: "\(AppConstants.IMDB_BASE_URL)/\(currentMovieImbdId)") else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false

        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }

    private func setupMovieContentView() {
        movieContentView.backgroundColor = .systemBackground
        contentView.addSubview(movieContentView)

        seperator.backgroundColor = .quaternaryLabel
        movieContentView.addSubview(seperator)
    }

    private func setupLabels() {
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textColor = .label
        titleLabel.text = currentMovie.title

        overviewLabel.font = .preferredFont(forTextStyle: .body)
        overviewLabel.textColor = .secondaryLabel
        overviewLabel.numberOfLines = 0
        overviewLabel.lineBreakMode = .byWordWrapping
        overviewLabel.text = currentMovie.overview

        starLabel.font = .preferredFont(forTextStyle: .subheadline)
        starLabel.textColor = .secondaryLabel
        starLabel.text = String(currentMovie.voteAverage)

        releaseDateLabel.font = .preferredFont(forTextStyle: .subheadline)
        releaseDateLabel.textColor = .secondaryLabel
        releaseDateLabel.text = currentMovie.releaseDate

        movieContentView.addSubview(titleLabel)
        movieContentView.addSubview(overviewLabel)
    }

    private func setupMovieInfoStackView() {
        starImageView.tintColor = .systemYellow

        infoStackView = UIStackView(arrangedSubviews: [starImageView, starLabel, releaseDateLabel, imdbImageView])
        infoStackView.axis = .horizontal
        infoStackView.spacing = 15
        infoStackView.setCustomSpacing(5, after: starImageView)
        infoStackView.translatesAutoresizingMaskIntoConstraints = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(imdbImageTapped))
        imdbImageView.addGestureRecognizer(tap)
        imdbImageView.isUserInteractionEnabled = true

        movieContentView.addSubview(infoStackView)
    }

    private func configureAutoLayout() {
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            movieImageView.heightAnchor.constraint(equalToConstant: ScreenSize.height * 0.3),

            movieContentView.topAnchor.constraint(equalTo: movieImageView.bottomAnchor),
            movieContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            movieContentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0.0),

            similarMoviesCollectionView.topAnchor.constraint(equalTo: movieContentView.bottomAnchor, constant: 12),
            similarMoviesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            similarMoviesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            similarMoviesCollectionView.heightAnchor.constraint(equalToConstant: ScreenSize.height * 0.2),
            similarMoviesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: movieContentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: movieContentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: movieContentView.trailingAnchor, constant: -12),

            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: movieContentView.leadingAnchor, constant: 12),
            overviewLabel.trailingAnchor.constraint(equalTo: movieContentView.trailingAnchor, constant: -12),

            starImageView.topAnchor.constraint(equalTo: infoStackView.topAnchor),
            starImageView.bottomAnchor.constraint(equalTo: infoStackView.bottomAnchor),

            imdbImageView.widthAnchor.constraint(equalToConstant: 60),
            imdbImageView.topAnchor.constraint(equalTo: infoStackView.topAnchor),
            imdbImageView.bottomAnchor.constraint(equalTo: infoStackView.bottomAnchor),

            infoStackView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 12),
            infoStackView.trailingAnchor.constraint(equalTo: movieContentView.trailingAnchor, constant: -12),
            infoStackView.heightAnchor.constraint(equalToConstant: 30),

            seperator.heightAnchor.constraint(equalToConstant: 1),
            seperator.widthAnchor.constraint(equalTo: movieContentView.widthAnchor),
            seperator.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 12),
            seperator.bottomAnchor.constraint(equalTo: movieContentView.bottomAnchor),
        ])
    }
}

// MARK: - Collection View Methods

extension MovieDetailViewController: UICollectionViewDelegate {
    private func setupSimilarMoviesCollectionView() {
        similarMoviesCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        similarMoviesCollectionView.delegate = self
        similarMoviesCollectionView.backgroundColor = .systemBackground
        similarMoviesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        similarMoviesCollectionView.register(SimilarSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimilarSectionHeader.reuseIdentifier)
        similarMoviesCollectionView.register(SimilarMovieCell.self, forCellWithReuseIdentifier: SimilarMovieCell.reuseIdentifier)
        contentView.addSubview(similarMoviesCollectionView)
        similarMoviesCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSimilarMoviesDataSource() {
        similarMoviesDataSource = UICollectionViewDiffableDataSource<SimilarSection, MovieListItem>(collectionView: similarMoviesCollectionView) { (collectionView, indexPath, movie) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimilarMovieCell.reuseIdentifier, for: indexPath) as? SimilarMovieCell
            cell?.configure(with: movie)
            return cell
        }

        similarMoviesDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SimilarSectionHeader.reuseIdentifier, for: indexPath) as? SimilarSectionHeader else { return nil }
            return sectionHeader
        }
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .continuous

        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(20))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

        section.boundarySupplementaryItems = [layoutSectionHeader]

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func createSnapshot(from movies: [MovieListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<SimilarSection, MovieListItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies)
        similarMoviesDataSource.apply(snapshot, animatingDifferences: true)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movieDetailViewModel.similarMovies.value[indexPath.row]
        // It will trigger navigate to detail screen
        movieDetailManager.getImdbIdOfMovie(movie: movie, vc: self)
    }
}
