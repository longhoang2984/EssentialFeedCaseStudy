//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 06/10/2022.
//

import XCTest
import EssentialFeed

private class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

    func test_retrieveEmptyResultOnEmptyCached() {
        let sut = CodableFeedStore()
    
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expect receive empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveTwiceGetTheSameEmptyResult() {
        let sut = CodableFeedStore()
    
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expect retrieving twice from empty cache to deliver same empty result, got \(firstResult) \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
}
