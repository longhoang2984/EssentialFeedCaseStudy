//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Cửu Long Hoàng on 16/11/2022.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {

    func test_launch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRederedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    
    func test_launch_displayCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let shareStore = InMemoryFeedStore.empty
        
        let onlineFeed = launch(httpClient: .online(response), store: shareStore)
        XCTAssertEqual(onlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(onlineFeed.renderedFeedImageData(at: 1), makeImageData())
        
        let offlineFeed = launch(httpClient: .offline, store: shareStore)
        XCTAssertEqual(offlineFeed.numberOfRederedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_launch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCached() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRederedFeedImageViews(), 0)
    }

    // MARK: - Helpers
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        private var feedCache: CacheFeed?
        private var feedImageDataCache: [URL: Data] = [:]
        
        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }
        
        func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache = CacheFeed(feed: feeds, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "items": [
                ["id": UUID().uuidString, "image": "https://image.com"],
                ["id": UUID().uuidString, "image": "https://image.com"],
            ]
        ])
    }
}
