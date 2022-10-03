//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 03/10/2022.
//

import XCTest
import EssentialFeed

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertions = [(items: [FeedItem], timeStamp: Date)]()
    
    private var deletionCompletions = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completionWithError(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completionWithSuccessfulDeletion(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        insertions.append((items, timestamp))
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

final class CachedFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completionWithError(deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestNewItemsCacheInsertionWithTimestampOnSuccessfullDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        sut.save(items)
        store.completionWithSuccessfulDeletion()
        
        XCTAssertEqual(store.insertions.first?.timeStamp, timestamp)
        XCTAssertEqual(store.insertions.first?.items, items)
    }
    
    // MARK: - Helpers
    func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
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

}
