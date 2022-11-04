//
//  XCTest+Helpers.swift
//  EssensialAppTests
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "error", code: 1)
}

func anyData() -> Data {
    return Data("any data".utf8)
}
