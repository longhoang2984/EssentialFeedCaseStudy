//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 27/09/2022.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://google.com")!
        let (_, client) = makeSUT(url: url)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "https://google.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in }
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failed(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.completion(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samplesStatusCode = [199, 201, 400, 404, 500, 501]
        samplesStatusCode.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failed(.invalidData)) {
                let json = makeItemsData([])
                client.completion(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failed(.invalidData)) {
            let data = Data("Invalid JSON".utf8)
            client.completion(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyListSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let data = makeItemsData([])
            client.completion(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItems(id: UUID(),
                              imageUrl: URL(string: "https://images.com")!)
        let item2 = makeItems(id: UUID(), description: "description",
                              location: "location",
                              imageUrl: URL(string: "https://images.com")!)
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
            let data = makeItemsData([item1.json, item2.json])
            client.completion(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDellocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var captureResults = [RemoteFeedLoader.Result]()
        sut?.load { captureResults.append($0) }
        
        sut = nil
        client.completion(withStatusCode: 2000, data: makeItemsData([]))
        
        XCTAssertTrue(captureResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        checkForMemoryLeaks(sut)
        checkForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leaks", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturesResults = [RemoteFeedLoader.Result]()
        sut.load { capturesResults.append($0) }
        action()
        XCTAssertEqual(capturesResults, [result], file: file, line: line)
    }
    
    private func makeItems(id: UUID, description: String? = nil,
                           location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageUrl)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        
        return (item, json)
    }
    
    private func makeItemsData(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map({ $0.url })
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func completion(with error: Error, at index: Int = 0) {
            messages[index].completion(.failed(error))
        }
        
        func completion(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
    
}
