//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 07/10/2022.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversFailureOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = delete(sut)
        XCTAssertNotNil(error, "Expected cache deletion to failed", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(sut)
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
