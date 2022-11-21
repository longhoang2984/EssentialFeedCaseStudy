//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 26/10/2022.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE", tableName: "Feed"))
    }
    
    func test_map_createViewModels() {
        let feed = uniqueFeeds().models
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)

    }
}
