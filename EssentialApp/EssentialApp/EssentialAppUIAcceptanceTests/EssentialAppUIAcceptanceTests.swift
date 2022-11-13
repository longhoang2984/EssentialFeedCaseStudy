//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Cửu Long Hoàng on 13/11/2022.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    func test_launch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.cells.firstMatch.images.matching(identifier: "FeedImageView").count, 1)
    }
}
