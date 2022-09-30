//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 30/09/2022.
//

import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(_ session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURLSession_createDataTaskWithURL() {
        let url = URL(string: "https://google.com")!
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session)
        
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs.count, 1)
    }
    
    func test_getFromURLSession_resumesDataTaskWithURL() {
        let url = URL(string: "https://google.com")!
        
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session)
        
        sut.get(from: url)
        XCTAssertEqual(task.resumesCallCount, 1)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLs: [URL] = []
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumesCallCount = 0
        
        override func resume() {
            resumesCallCount += 1
        }
    }

}
