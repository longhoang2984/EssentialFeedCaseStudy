//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 19/11/2022.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let samplesStatusCode = [199, 400, 404, 500, 501]
        let json = makeItemsData([])
        try samplesStatusCode.forEach { code in
            XCTAssertThrowsError(
                try RemoteImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let samplesStatusCode = [200, 240, 222, 299, 232]
        let invalidJSON = Data("Invalid JSON".utf8)
        try samplesStatusCode.forEach { code in
            XCTAssertThrowsError(
                try RemoteImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyListSON() throws {
        let emptyListJSON = makeItemsData([])
        let samplesStatusCode = [200, 240, 222, 299, 232]
        
        try samplesStatusCode.forEach { code in
            let result = try RemoteImageCommentsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1666195969), "2022-10-19T16:12:49+0000"),
            username: "a username")

        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1666282369), "2022-10-20T16:12:49+0000"),
            username: "another username")
        
        let json = makeItemsData([item1.json, item2.json])
        
        let samplesStatusCode = [200, 240, 222, 299, 232]
        
        try samplesStatusCode.forEach { code in
            let result = try RemoteImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }
    
    // MARK: - Helpers
    private func makeItem(id: UUID, message: String,
                           createdAt: (date: Date, ios8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.ios8601String,
            "author": [
                "username": username
            ]
        ]
        
        return (item, json)
    }

}
