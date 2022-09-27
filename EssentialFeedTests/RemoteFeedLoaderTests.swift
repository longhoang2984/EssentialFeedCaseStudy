//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 27/09/2022.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
