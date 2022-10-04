//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 03/10/2022.
//

import XCTest
import EssentialFeed

final class CachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let feeds = [uniqueFeed(), uniqueFeed()]
        let (sut, store) = makeSUT()
        sut.save(feeds) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let feeds = [uniqueFeed(), uniqueFeed()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(feeds) { _ in }
        store.completionWithDeletionError(deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewItemsCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let feeds = uniqueFeeds()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(feeds.models) { _ in }
        store.completionWithSuccessfulDeletion()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .inert(feeds.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let timestamp = Date()
        let error = anyNSError()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        expect(sut, toCompletionWithError: error) {
            store.completionWithDeletionError(error)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let timestamp = Date()
        let error = anyNSError()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        expect(sut, toCompletionWithError: error) {
            store.completionWithSuccessfulDeletion()
            store.completionWithInsertionError(error)
        }
    }
    
    func test_save_succeedsOnSuccessfulCachedInsertion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        expect(sut, toCompletionWithError: nil) {
            store.completionWithSuccessfulDeletion()
            store.completionWithSuccessfulInsertion()
        }
    }
    
    func test_save_doesNotReceiveDeletionErrorAfterSUTInstanceHasBeenDellocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors: [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueFeed()]) { receivedErrors.append($0) }
        sut = nil
        store.completionWithDeletionError(anyNSError())
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotReceiveInsertionErrorAfterSUTInstanceHasBeenDellocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors: [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueFeed()]) { receivedErrors.append($0) }
        store.completionWithSuccessfulDeletion()
        sut = nil
        store.completionWithInsertionError(anyNSError())
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    // MARK: - Helpers
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompletionWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.save([uniqueFeed()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    func uniqueFeed() -> FeedImage {
        return FeedImage(id: UUID(), description: "desc", location: "location", imageURL: anyURL())
    }
    
    func uniqueFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let items = [uniqueFeed(), uniqueFeed()]
        let local = items.map({ return LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) })
        return (items, local)
    }
    
    func anyURL() -> URL {
        return URL(string: "https://url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "error", code: 1)
    }
}
