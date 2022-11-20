//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 20/11/2022.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {

    func test_feed_deliversNoErrorOnLoading() {
        let (sut, spy) = makeSUT()
        
        sut.didStartLoading()
        XCTAssertEqual(spy.messages, [.display(error: nil), .display(isLoading: true)])
    }
    
    func test_feed_deliversErrorOnLoadFeedError() {
        let (sut, spy) = makeSUT()
        
        let error = anyNSError()
        sut.didFinishLoading(with: error as Error)
        XCTAssertEqual(spy.messages, [.display(error: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }
    
    func test_feed_deliversFeedOnFeedLoadSuccessfully() {
        let (sut, spy) = makeSUT()
        
        let (item, _) = makeItems(id: UUID(), imageUrl: anyURL())
        sut.didFinishLoading(with: [item])
        XCTAssertEqual(spy.messages, [.display(feed: [item]), .display(isLoading: false)])
    }
    
    // MARK: - Helper
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: LoadResourcePresenter, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = LoadResourcePresenter(loadingView: spy, feedView: spy, errorView: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        enum Message: Hashable {
            case display(error: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages: Set<Message> = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(error: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }

}
