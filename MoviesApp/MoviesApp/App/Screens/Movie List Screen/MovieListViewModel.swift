//
//  MovieListViewModel.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 19.06.2021.
//

import Combine
import Foundation
import UIKit

class MovieListViewModel {
    var cancellables = Set<AnyCancellable>()

    let movieListItems = CurrentValueSubject<[ListSection], Never>([ListSection(type: .nowPlaying, title: "Now Playing", items: []), ListSection(type: .upcoming, title: "Upcoming", items: [])])
    var isSearchMode = CurrentValueSubject<Bool, Never>(false)
    var isFirstPageLoading = CurrentValueSubject<Bool, Never>(true)

    private var isLoadingUpcomingPage = false
    var cachedSections = [ListSection]()
    var canLoadMoreUpcoming = true
    var currentUpcomingPage = 1
    var currentSearchQuery = ""

    func getNowPlayingMovies(vc: UIViewController) {
        let nowPlayingPublisher: Future<GeneralPaginatedResult<MovieListItem>, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.getNowPlaying().url, httpMethod: HTTPTypes.GET.rawValue)

        nowPlayingPublisher.sink { [weak self] completion in
            if case let .failure(apiError) = completion {
                print(apiError.statusMessage)
                self?.isFirstPageLoading.value = false
                self?.getUpcomingMovies(vc: vc)
                vc.showSimpleAlert(title: "Error", message: "Network Error")
                print("Network Error")
            }
        } receiveValue: { [weak self] movieList in
            guard let sectionIndex = self?.movieListItems.value.firstIndex(where: { $0.type == .nowPlaying }) else { return }
            self?.movieListItems.value[sectionIndex].items = movieList.results
            self?.getUpcomingMovies(vc: vc)
        }
        .store(in: &cancellables)
    }

    func getUpcomingMovies(vc: UIViewController) {
        guard !isLoadingUpcomingPage, canLoadMoreUpcoming else {
            return
        }
        isLoadingUpcomingPage = true

        let upcomingPublisher: Future<GeneralPaginatedResult<MovieListItem>, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.getUpcoming(page: currentUpcomingPage).url, httpMethod: HTTPTypes.GET.rawValue)

        upcomingPublisher.sink { completion in
            if case let .failure(apiError) = completion {
                print(apiError.statusMessage)
                vc.showSimpleAlert(title: "Error", message: "Network Error")
            }
        } receiveValue: { [weak self] movieList in
            guard let sectionIndex = self?.movieListItems.value.firstIndex(where: { $0.type == .upcoming }) else { return }
            if movieList.totalPagesCount <= self?.currentUpcomingPage ?? 0 {
                self?.canLoadMoreUpcoming = false
            }
            if self?.currentUpcomingPage == 1 {
                self?.movieListItems.value[sectionIndex].items.removeAll()
            }
            self?.currentUpcomingPage += 1

            self?.movieListItems.value[sectionIndex].items.append(contentsOf: movieList.results)
            self?.isLoadingUpcomingPage = false
            self?.isFirstPageLoading.value = false
        }
        .store(in: &cancellables)
    }

    func getSearchedMovies(vc: UIViewController) {
        let searchPublisher: Future<GeneralPaginatedResult<MovieListItem>, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.searchMovie(searchQuery: currentSearchQuery).url, httpMethod: HTTPTypes.GET.rawValue)

        searchPublisher.sink { completion in
            if case let .failure(apiError) = completion {
                print(apiError.statusMessage)
                vc.showSimpleAlert(title: "Error", message: "Network Error")
            }
        } receiveValue: { [weak self] movieList in
            guard let sectionIndex = self?.movieListItems.value.firstIndex(where: { $0.type == .search }) else { return }
            self?.movieListItems.value[sectionIndex].items = movieList.results
        }
        .store(in: &cancellables)
    }
}
