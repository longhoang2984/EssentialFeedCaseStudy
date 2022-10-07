//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 07/10/2022.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversFailureOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeeds()
        let timestamp = Date()
        let insertionError = insert((feed.local, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected to insert cache failure with an error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeeds()
        let timestamp = Date()
        insert((feed.local, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}
