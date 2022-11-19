//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 19/11/2022.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        let samplesStatusCode = [199, 400, 404, 500, 501]
        samplesStatusCode.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsData([])
                client.completion(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samplesStatusCode = [200, 240, 222, 299, 232]
        
        samplesStatusCode.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let data = Data("Invalid JSON".utf8)
                client.completion(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithEmptyListSON() {
        let (sut, client) = makeSUT()
        
        let samplesStatusCode = [200, 240, 222, 299, 232]
        
        samplesStatusCode.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                let data = makeItemsData([])
                client.completion(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithSONItems() {
        let (sut, client) = makeSUT()
        
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
        
        let samplesStatusCode = [200, 240, 222, 299, 232]
        
        samplesStatusCode.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
                let data = makeItemsData([item1.json, item2.json])
                client.completion(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let expect = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            expect.fulfill()
        }
        action()
        wait(for: [expect], timeout: 1.0)
       
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
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
