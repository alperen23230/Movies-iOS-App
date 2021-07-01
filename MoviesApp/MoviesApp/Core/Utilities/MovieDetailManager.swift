//
//  MovieDetailManager.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Combine
import Foundation
import UIKit

class MovieDetailManager {
    var cancellables = Set<AnyCancellable>()
    var currentImdbId = CurrentValueSubject<String, Never>("")
    var willSendMovieDetail: MovieListItem?

    func getImdbIdOfMovie(movie: MovieListItem, vc: UIViewController) {
        let detailPublisher: Future<MovieDetailItem, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.getMovieDetail(id: movie.id).url, httpMethod: HTTPTypes.GET.rawValue)

        detailPublisher.sink { completion in
            if case let .failure(apiError) = completion {
                print(apiError.statusMessage)
                vc.showSimpleAlert(title: "Error", message: "Network Error")
            }
        } receiveValue: { [weak self] movieDetail in
            self?.willSendMovieDetail = movie
            self?.currentImdbId.value = movieDetail.imdbId ?? ""
        }
        .store(in: &cancellables)
    }
}
