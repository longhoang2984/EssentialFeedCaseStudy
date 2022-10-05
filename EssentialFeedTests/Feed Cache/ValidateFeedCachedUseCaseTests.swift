//
//  ValidateFeedCachedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 05/10/2022.
//

import XCTest
import EssentialFeed

final class ValidateFeedCachedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deleteCachedOnRetrieveError() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completionWithRetrievalError(anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
        
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
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
