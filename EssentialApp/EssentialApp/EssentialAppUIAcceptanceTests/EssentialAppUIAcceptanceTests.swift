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
        
        let feedCells = app.cells.matching(identifier: "FeedImageCell")
        XCTAssertEqual(feedCells.count, 22)
        
        let firstImage = app.images.matching(identifier: "FeedImageView").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
}
