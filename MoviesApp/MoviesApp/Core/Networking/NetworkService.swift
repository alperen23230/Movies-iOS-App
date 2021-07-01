//
//  NetworkService.swift
//  MoviesApp
//
//  Created by Alperen Ünal on 17.06.2021.
//

import Combine
import Foundation

enum HTTPTypes: String {
    case GET, POST
}

class NetworkService {
    static var sharedInstance = NetworkService()

    var cancellables = Set<AnyCancellable>()

    private func fetchWithURLRequest<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { $0 as Error }
            .flatMap { result -> AnyPublisher<T, Error> in
                guard let urlResponse = result.response as? HTTPURLResponse, (200 ... 299).contains(urlResponse.statusCode) else {
                    return Just(result.data)
                        .decode(type: APIError.self, decoder: JSONDecoder()).tryMap { errorModel in
                            throw errorModel
                        }
                        .eraseToAnyPublisher()
                }
                return Just(result.data).decode(type: T.self, decoder: JSONDecoder())
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getData<T: Decodable>(from url: URL, httpMethod: String) -> Future<T, APIError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        // Apply bearer token on every request header
        urlRequest.addValue("Bearer \(AppConstants.BEARER_TOKEN)", forHTTPHeaderField: "Authorization")

        let publisher: AnyPublisher<T, Error> = fetchWithURLRequest(urlRequest)
        return Future { promise in
            publisher.sink { completion in
                if case let .failure(error) = completion, let apiError = error as? APIError {
                    promise(.failure(apiError))
                }
            } receiveValue: { responseModel in
                promise(.success(responseModel))
            }
            .store(in: &self.cancellables)
        }
    }
}
