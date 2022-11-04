//
//  FeedImageLoaderWithFallbackCompositeTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 04/11/2022.
//

import XCTest
import EssentialFeed

class FeedImageLoaderWithFallbackComposite {
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapper?.cancel()
        }
    }
    
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        
        task.wrapper = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty)
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadImageFromPrimaryFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected does not load URL from fallback loader")
    }
    
    func test_loadImageData_loadImageFromFallbackOnPrimaryFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        _ = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }
    
    func test_loadImageData_cancelsPrimaryLoaderOnTaskCancel() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancelled URL loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URL loading from fallback loader")
    }
    
    func test_loadImageData_cancelsFallbackLoaderOnTaskCancelOnPrimaryFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URL loading from primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancelled URL loading from fallback loader")
    }
    
    func test_loadImageData_deliversImageDataOnPrimarySuccess() {
        let data = anyData()
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, toCompleteWith: .success(data)) {
            primaryLoader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliversImageDataOnFallbackLoaderSuccessAfterPrimaryLoaderFailure() {
        let data = anyData()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(data)) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: data)
        }
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryLoaderAndFallbackLoaderFailure() {
        let data = anyData()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageLoaderWithFallbackComposite, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leaks", file: file, line: line)
        }
    }
    
    private func expect(_ sut: FeedImageLoaderWithFallbackComposite, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void,file: StaticString = #file, line: UInt = #line) {
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
    
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "error", code: 1)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private(set) var cancelledURLs: [URL] = []
        
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
}
