//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 29/10/2022.
//

import XCTest

private final class LocalFeedImageDataLoader {
    init(store: Any) {
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) ->  (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let spy = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: spy)
        trackForMemoryLeaks(spy)
        trackForMemoryLeaks(sut)
        return (sut, spy)
    }
    
    private class FeedStoreSpy {
        let receivedMessages = [Any]()
    }

}
