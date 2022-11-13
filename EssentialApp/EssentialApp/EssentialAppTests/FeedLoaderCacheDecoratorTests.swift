//
//  FeedLoaderCacheDecoratorTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTests {

    func test_load_deliversFeedOnLoaderSuccess() {
        
        let feed = uniqueFeeds()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnErrorFailure() {
        
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoaderFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeeds()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    func test_load_doesNotCachOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        private(set) var messages = [Message]()
        
        func save(_ feeds: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feeds))
            completion(.success(()))
        }
    }
}
