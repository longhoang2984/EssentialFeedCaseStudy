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
    
    func test_validateCache_doesNotDeleteCachedOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completionRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCachedLessThanSevenDaysOld() {
        let feed = uniqueFeeds()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.add(days: -7).add(seconds: 1)
        let (sut, store) = makeSUT { fixedCurrentDate }
        
        sut.validateCache()
        store.completionRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
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
    
    func uniqueFeed() -> FeedImage {
        return FeedImage(id: UUID(), description: "desc", location: "location", imageURL: anyURL())
    }
    
    func uniqueFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let items = [uniqueFeed(), uniqueFeed()]
        let local = items.map({ return LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) })
        return (items, local)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://google.com")!
    }
}

private extension Date {
    func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func add(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
