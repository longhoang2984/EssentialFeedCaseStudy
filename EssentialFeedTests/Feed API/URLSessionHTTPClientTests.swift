//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 30/09/2022.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: URLSession
    
    init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (LoadFeedResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performGetRequestWithURL() {
        let url = URL(string: "https://google.com")!
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURLSession_failedOnRequestURL() {
        
        let url = URL(string: "https://google.com")!
        let error = NSError(domain: "error", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let exp = expectation(description: "Wait for completion")
        makeSUT().get(from: url) { result in
            switch result {
            case .failure(let err as NSError):
                XCTAssertEqual(err.domain, error.domain)
                XCTAssertEqual(err.code, error.code)
            default:
                XCTFail("Expected receive failure with error \(error) but received \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leaks", file: file, line: line)
        }
    }
    
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        static func stub(url: URL,
            data: Data?,
            response: URLResponse?,
            error: Error? = nil) {
            URLProtocolStub.stub = Stub(data: data,
                                              response: response,
                                              error: error)
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            URLProtocolStub.stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
