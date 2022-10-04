//
//  LoadCachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 04/10/2022.
//

import XCTest
import EssentialFeed

final class LoadCachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let error = anyNSError()
        let (sut, store) = makeSUT()

        let exp = expectation(description: "Wait for completion")
        var retrievedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                retrievedError = error
            default:
                XCTFail("Expect error \(error), but get \(result) instead")
            }
            exp.fulfill()
        }
        store.completionWithRetrievalError(error)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(retrievedError as? NSError, error)
    }
    
    // MARK: - Helpers
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "error", code: 1)
    }
}
