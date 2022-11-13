//
//  FeedImageLoaderWithFallbackCompositeTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 04/11/2022.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTests {

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
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageLoaderWithFallbackComposite, primary: FeedImageLoaderSpy, fallback: FeedImageLoaderSpy) {
        let primaryLoader = FeedImageLoaderSpy()
        let fallbackLoader = FeedImageLoaderSpy()
        let sut = FeedImageLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
}