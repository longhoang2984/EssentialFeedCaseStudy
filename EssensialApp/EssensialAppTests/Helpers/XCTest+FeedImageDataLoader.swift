//
//  XCTest+FeedImageDataLoader.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTests: XCTestCase {}

extension FeedImageDataLoaderTests {
    func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void,file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait to completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
