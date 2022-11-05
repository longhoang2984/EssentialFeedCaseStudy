//
//  FeedLoaderCacheDecoratorTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feeds: [FeedImage], completion: @escaping (Result) -> Void)
}

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save((try? result.get())  ?? [], completion: { _ in })
            completion(result)
        }
    }
}

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
