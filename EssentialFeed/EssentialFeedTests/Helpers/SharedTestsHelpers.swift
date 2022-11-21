//
//  SharedTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 05/10/2022.
//

import EssentialFeed

func anyURL() -> URL {
    return URL(string: "https://google.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "error", code: 1)
}

func anyData() -> Data {
    return Data()
}

func makeItems(id: UUID, description: String? = nil,
                       location: String? = nil, imageUrl: URL) -> (model: FeedImage, json: [String: Any]) {
    let item = FeedImage(id: id, description: description, location: location, imageURL: imageUrl)
    
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

func makeItemsData(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}
