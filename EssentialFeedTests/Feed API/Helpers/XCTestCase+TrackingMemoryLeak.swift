//
//  XCTestCase+TrackingMemoryLeak.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 30/09/2022.
//

import Foundation

func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
        XCTAssertNil(instance, "Instance should have been dellocated. Potential memory leaks", file: file, line: line)
    }
}
