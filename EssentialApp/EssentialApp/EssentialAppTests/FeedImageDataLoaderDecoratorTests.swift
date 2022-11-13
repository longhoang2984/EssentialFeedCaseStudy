//
//  FeedImageDataLoaderDecoratorTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderDecoratorTests: XCTestCase, FeedImageDataLoaderTests {

    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let imageData = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            loader.complete(with: imageData)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
    }
    
    func test_loadImageData_cacheImageDataOnLoaderSuccess() {
        let cache = FeedImageCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        _ = sut.loadImageData(from: anyURL()) { _ in }
        loader.complete(with: anyImageData())
        
        XCTAssertEqual(cache.messages, [.save(anyImageData())])
    }
    
    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let cache = FeedImageCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        _ = sut.loadImageData(from: anyURL()) { _ in }
        loader.complete(with: anyNSError())
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(cache: FeedImageCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderDecorator, loader: FeedImageLoaderSpy) {
        let loader = FeedImageLoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private class FeedImageCacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(Data)
        }
        
        private(set) var messages = [Message]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data))
            completion(.success(()))
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
