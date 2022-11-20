//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 27/09/2022.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
    func test_load_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsData([])
        let samplesStatusCode = [199, 400, 404, 500, 501]
        try samplesStatusCode.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_load_throwErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("Invalid JSON".utf8)
        let samplesStatusCode = [200, 240, 222, 299, 232]
        
        try samplesStatusCode.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyListSON() throws {
        let emptyListJson = makeItemsData([])
        
        let result = try FeedItemsMapper.map(emptyListJson, HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [])
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithSONItems() throws {
        let item1 = makeItems(id: UUID(),
                              imageUrl: URL(string: "https://images.com")!)
        let item2 = makeItems(id: UUID(), description: "description",
                              location: "location",
                              imageUrl: URL(string: "https://images.com")!)
        
        let json = makeItemsData([item1.json, item2.json])
        let result = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
}
