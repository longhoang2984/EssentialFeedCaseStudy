//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 04/11/2022.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite {
    private let primary: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversRemoteFeedLoaderOnRemoteSuccess() {
        let primaryFeed = uniqueFeeds()
        let fallbackFeed = uniqueFeeds()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expected load feed successfull, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func uniqueFeeds() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "desc", location: "location", imageURL: anyURL())]
    }
    
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }

    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
