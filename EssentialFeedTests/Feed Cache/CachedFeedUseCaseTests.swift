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
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completionWithDeletionError(deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewItemsCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(items) { _ in }
        store.completionWithSuccessfulDeletion()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .inert(items, timestamp)])
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
        
        var receivedErrors: [Error?] = []
        sut?.save([uniqueItem()]) { receivedErrors.append($0) }
        sut = nil
        store.completionWithDeletionError(anyNSError())
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func test_save_doesNotReceiveInsertionErrorAfterSUTInstanceHasBeenDellocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedErrors: [Error?] = []
        sut?.save([uniqueItem()]) { receivedErrors.append($0) }
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
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "desc", location: "location", imageURL: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "error", code: 1)
    }
    
    class FeedStoreSpy: FeedStore {
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case inert([FeedItem], Date)
        }
        
        private(set) var receivedMessages: [ReceivedMessage] = []
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        
        func completionWithDeletionError(_ error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completionWithInsertionError(_ error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completionWithSuccessfulDeletion(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.inert(items, timestamp))
        }
        
        func completionWithSuccessfulInsertion(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }

}
