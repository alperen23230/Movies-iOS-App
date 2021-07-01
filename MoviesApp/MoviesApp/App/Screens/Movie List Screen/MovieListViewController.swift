//
//  MovieListViewController.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 19.06.2021.
//

import Combine
import Resolver
import UIKit

class MovieListViewController: UIViewController {
    // CollectionView and Data Sources
    private let moviesSearchController = UISearchController()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ListSection, MovieListItem>?

    // Injected variables
    @LazyInjected private var movieListViewModel: MovieListViewModel
    @LazyInjected private var movieDetailManager: MovieDetailManager

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureSearchController()
        setSearchControllerListeners()
        setupCollectionView()
        createDataSource()
        setViewModelListeners()
        movieListViewModel.getNowPlayingMovies(vc: self)
    }

    private func configureNavBar() {
        navigationItem.searchController = moviesSearchController
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Movies App"
    }
}

// MARK: - View Model Listeners

extension MovieListViewController {
    private func setViewModelListeners() {
        Publishers.CombineLatest(movieListViewModel.movieListItems, movieListViewModel.isFirstPageLoading).sink {
            [weak self] sections, isFirstLoading in
            if isFirstLoading {
                self?.collectionView.setLoading()
            } else {
                self?.collectionView.restore()
                self?.createSnapshot(from: sections)
            }
        }
        .store(in: &movieListViewModel.cancellables)

        movieListViewModel.isSearchMode.sink { [weak self] isSearchMode in
            if isSearchMode {
                self?.movieListViewModel.cachedSections = self?.movieListViewModel.movieListItems.value ?? []
                self?.movieListViewModel.movieListItems.value.removeAll()
                self?.movieListViewModel.movieListItems.value.append(ListSection(type: .search, title: "Search", items: []))
            } else {
                if self?.movieListViewModel.movieListItems.value.count == 1 {
                    self?.movieListViewModel.movieListItems.value.removeAll()
                    self?.movieListViewModel.movieListItems.value = self?.movieListViewModel.cachedSections ?? []
                }
            }
        }
        .store(in: &movieListViewModel.cancellables)

        movieDetailManager.currentImdbId.sink { [weak self] currentId in
            guard let willSendMovie = self?.movieDetailManager.willSendMovieDetail else { return }
            self?.navigationController?.pushViewController(MovieDetailViewController(movie: willSendMovie, imdbId: currentId), animated: true)
        }
        .store(in: &movieDetailManager.cancellables)
    }
}

// MARK: - Collection View Methods

extension MovieListViewController: UICollectionViewDelegate {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayoutForPage())
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(NowPlayingCell.self, forCellWithReuseIdentifier: NowPlayingCell.reuseIdentifier)
        collectionView.register(UpcomingCell.self, forCellWithReuseIdentifier: UpcomingCell.reuseIdentifier)
        collectionView.register(SearchItemCell.self, forCellWithReuseIdentifier: SearchItemCell.reuseIdentifier)
        view.addSubview(collectionView)
    }

    private func configureCell<T: SelfConfiguringCell>(_ cellType: T.Type, with movie: MovieListItem, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else { fatalError("Unable to dequeue \(cellType)") }
        cell.configure(with: movie)
        return cell
    }

    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ListSection, MovieListItem>(collectionView: collectionView) {
            _, indexPath, movie in
            switch self.movieListViewModel.movieListItems.value[indexPath.section].type {
            case .nowPlaying:
                return self.configureCell(NowPlayingCell.self, with: movie, for: indexPath)
            case .upcoming:
                return self.configureCell(UpcomingCell.self, with: movie, for: indexPath)
            case .search:
                return self.configureCell(SearchItemCell.self, with: movie, for: indexPath)
            }
        }
    }

    private func createSnapshot(from addedSections: [ListSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<ListSection, MovieListItem>()
        snapshot.appendSections(addedSections)
        for section in addedSections {
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func createCompositionalLayoutForPage() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = self.movieListViewModel.movieListItems.value[sectionIndex]

            switch section.type {
            case .nowPlaying:
                return self.createNowPlayingSection(using: section)
            case .upcoming:
                return self.createUpcomingSection(using: section)
            case .search:
                return self.createSearchSection(using: section)
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config

        return layout
    }

    private func createNowPlayingSection(using _: ListSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(250))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        return layoutSection
    }

    private func createUpcomingSection(using _: ListSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(160))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)

        return layoutSection
    }

    private func createSearchSection(using _: ListSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(50))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)

        return layoutSection
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = movieListViewModel.movieListItems.value[indexPath.section]
        let movie = section.items[indexPath.row]
        // It will trigger navigate to detail screen
        movieDetailManager.getImdbIdOfMovie(movie: movie, vc: self)
    }
}

// MARK: - Scroll Methods

extension MovieListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let collectionViewContentSizeHeight = collectionView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if position > (collectionViewContentSizeHeight - 100 - scrollViewHeight) {
            movieListViewModel.getUpcomingMovies(vc: self)
        }
    }
}

// MARK: - Search Bar Methods

extension MovieListViewController: UISearchBarDelegate {
    private func configureSearchController() {
        moviesSearchController.searchBar.delegate = self
        moviesSearchController.searchBar.placeholder = "Search a Movie"
        moviesSearchController.obscuresBackgroundDuringPresentation = false
    }

    private func setSearchControllerListeners() {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: moviesSearchController.searchBar.searchTextField)
            .map {
                ($0.object as! UISearchTextField).text
            }
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                guard let strongSelf = self else { return }
                guard let query = searchQuery else { return }
                if query.getWordNumber() < 2 { return }

                if !strongSelf.movieListViewModel.isSearchMode.value {
                    strongSelf.movieListViewModel.isSearchMode.value = true
                }

                strongSelf.movieListViewModel.currentSearchQuery = query
                strongSelf.movieListViewModel.getSearchedMovies(vc: strongSelf)
            }
            .store(in: &movieListViewModel.cancellables)
    }

    func searchBarCancelButtonClicked(_: UISearchBar) {
        if movieListViewModel.isSearchMode.value {
            movieListViewModel.isSearchMode.value = false
        }
    }
}
