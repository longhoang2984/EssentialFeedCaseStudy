//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 30/09/2022.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(_ session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (LoadFeedResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success([]))
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURLSession_resumesDataTaskWithURL() {
        let url = URL(string: "https://google.com")!
        
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session)
        
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumesCallCount, 1)
    }
    
    func test_getFromURLSession_failedOnRequestURL() {
        let url = URL(string: "https://google.com")!
        
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "error", code: 1)
        session.stub(url: url, task: task, error: error)
        
        let sut = URLSessionHTTPClient(session)
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case .failure(let err as NSError):
                XCTAssertEqual(err, error)
            default:
                XCTFail("Expected receive failure with error \(error) but received \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        private var stubs = [URL: Stub]()
        func stub(url: URL,
                  task: URLSessionDataTask = FakeURLSessionDataTask(),
                  error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't file stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
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
