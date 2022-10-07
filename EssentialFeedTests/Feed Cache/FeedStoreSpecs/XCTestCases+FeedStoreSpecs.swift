//
//  XCTestCases+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 07/10/2022.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeeds()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed.local, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeeds()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed.local, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((uniqueFeeds().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeeds().local, Date()), to: sut)
        
        let latestFeed = uniqueFeeds().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = delete(sut)
        XCTAssertNil(error, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeeds()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut)
        
        delete(sut)
        
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatSideEffectsRunSerrially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var completionOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueFeeds().local, timestamp: Date(), completion: {_ in
            completionOperationsInOrder.append(op1)
            op1.fulfill()
        })
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completionOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueFeeds().local, timestamp: Date()) { _ in
            completionOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completionOperationsInOrder, [op1, op2, op3], file: file, line: line)
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var receivedError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertError in
            receivedError = insertError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    func delete(_ sut: FeedStore,  file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { error in
            deletionError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(receivedFeed, receivedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
}
