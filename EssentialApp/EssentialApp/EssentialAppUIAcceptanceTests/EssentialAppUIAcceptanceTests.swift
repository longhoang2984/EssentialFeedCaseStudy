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
        app.launchArguments = ["-reset"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "FeedImageCell")
        XCTAssertEqual(feedCells.count, 22)
        
        let firstImage = app.images.matching(identifier: "FeedImageView").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    
    func test_launch_displayCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset"]
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "FeedImageCell")
        XCTAssertEqual(cachedFeedCells.count, 22)
        
        let firstCachedImage = offlineApp.images.matching(identifier: "FeedImageView").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }
    
    func test_launch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCached() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "FeedImageCell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
