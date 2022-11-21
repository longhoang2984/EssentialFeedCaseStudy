//
//  LocalizedStringHelpers.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

import Foundation
import XCTest
import EssentialFeed

func localized(
    _ key: String,
    tableName: String,
    file: StaticString = #file,
    line: UInt = #line) -> String {
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: tableName)
    if value == key {
        XCTFail("Missing localized string for key \(key) in table \(tableName)", file: file, line: line)
    }
    return value
}
