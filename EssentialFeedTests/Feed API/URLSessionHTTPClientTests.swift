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
    
    func test_getFromURLSession_failedOnRequestURL() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "https://google.com")!
        let error = NSError(domain: "error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
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
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK: - Helpers
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let error: Error?
        }
        
        private static var stubs = [URL: Stub]()
        static func stub(url: URL,
                  error: Error? = nil) {
            URLProtocolStub.stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }

}
