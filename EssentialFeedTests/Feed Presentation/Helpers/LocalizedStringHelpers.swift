//
//  LocalizedStringHelpers.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

import Foundation
import XCTest

func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
        XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
    }
    return value
}
