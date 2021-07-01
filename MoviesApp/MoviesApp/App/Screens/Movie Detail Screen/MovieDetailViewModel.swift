//
//  MovieDetailViewModel.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 19.06.2021.
//

import Combine
import Foundation

class MovieDetailViewModel {
    var cancellables = Set<AnyCancellable>()

    var similarMovies = CurrentValueSubject<[MovieListItem], Never>([])
    var isLoadingSimilarMovies = CurrentValueSubject<Bool, Never>(false)

    func getSimilarMovies(with id: Int) {
        isLoadingSimilarMovies.value = true
        let similarMoviePublisher: Future<GeneralPaginatedResult<MovieListItem>, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.getSimilarMovies(id: id).url, httpMethod: HTTPTypes.GET.rawValue)

        similarMoviePublisher.sink { [weak self] completion in
            if case let .failure(apiError) = completion {
                print(apiError.statusMessage)
                self?.isLoadingSimilarMovies.value = false
            }
        } receiveValue: { [weak self] moviesList in
            self?.similarMovies.value = moviesList.results
            self?.isLoadingSimilarMovies.value = false
        }
        .store(in: &cancellables)
    }
}
