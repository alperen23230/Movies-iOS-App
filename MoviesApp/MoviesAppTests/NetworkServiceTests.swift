//
//  MoviesAppTests.swift
//  MoviesAppTests
//
//  Created by Alperen Ünal on 2.07.2021.
//

import XCTest
import Combine
@testable import MoviesApp

class NetworkServiceTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    private var expectationAPIResponse: XCTestExpectation!
    // System Under Test
    private var sut: NetworkService!
    private let timeoutForAPIResponse = 5.0
    
    
    override func setUp() {
        expectationAPIResponse = expectation(description: "API respond on time")
        sut = NetworkService()
    }
    
    override func tearDown() {
        expectationAPIResponse = nil
        sut = nil
    }
    
    func testGetNowPlayingMovies() {
        defer { waitForExpectations(timeout: timeoutForAPIResponse) }
        let nowPlayingPublisher: Future<GeneralPaginatedResult<MovieListItem>, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.getNowPlaying().url, httpMethod: HTTPTypes.GET.rawValue)
        nowPlayingPublisher.sink { (completion) in
            if case .failure(_) = completion {
                XCTFail("API return error on first page of now playing movies.")
            }
        } receiveValue: { [weak self] (response) in
            guard let self = self else { return XCTFail() }
            XCTAssertNotNil(response)
            do { self.expectationAPIResponse.fulfill() }
        }
        .store(in: &cancellables)
    }
    
    func testGetUpcomingMovies() {
        defer { waitForExpectations(timeout: timeoutForAPIResponse) }
        let upcomingPublisher: Future<GeneralPaginatedResult<MovieListItem>, APIError> = NetworkService.sharedInstance.getData(from: Endpoint.getUpcoming(page: 1).url, httpMethod: HTTPTypes.GET.rawValue)
        upcomingPublisher.sink { (completion) in
            if case .failure(_) = completion {
                XCTFail("API return error on first page of upcoming movies.")
            }
        } receiveValue: { [weak self] (response) in
            guard let self = self else { return XCTFail() }
            XCTAssertNotNil(response)
            do { self.expectationAPIResponse.fulfill() }
        }
        .store(in: &cancellables)
    }
    
}
