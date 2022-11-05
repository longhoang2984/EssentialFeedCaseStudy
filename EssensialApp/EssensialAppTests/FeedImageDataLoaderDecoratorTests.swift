//
//  FeedImageDataLoaderDecoratorTests.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
    
}

final class FeedImageDataLoaderDecoratorTests: XCTestCase, FeedImageDataLoaderTests {

    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let imageData = anyData()
        let loader = FeedImageLoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(imageData)) {
            loader.complete(with: imageData)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let loader = FeedImageLoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
    }
    
}
