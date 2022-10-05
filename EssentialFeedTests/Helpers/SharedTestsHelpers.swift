//
//  SharedTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 05/10/2022.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://google.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "error", code: 1)
}
