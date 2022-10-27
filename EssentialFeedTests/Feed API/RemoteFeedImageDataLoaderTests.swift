//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url] )
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url] )
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompletion: failure(.connectivity), when: {
            client.completion(with: anyNSError(), at: 0)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 303, 405, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompletion: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompletion: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        expect(sut, toCompletion: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var captureResults = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { captureResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        XCTAssertTrue(captureResults.isEmpty)
        
    }
    
    // MARK: - Helper
    private func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: spy)
        trackForMemoryLeaks(spy)
        trackForMemoryLeaks(sut)
        return (sut, spy)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompletion expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            func cancel() {}
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }
        
        func completion(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
}
