//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 26/10/2022.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedErrorViewModel {
    var message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

class FeedPresenter {
    let loadingView: FeedLoadingView
    let feedView: FeedView
    let errorView: FeedErrorView
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Feed load error")
    }
    
    init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {

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
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedPresenter(loadingView: spy, feedView: spy, errorView: spy)
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
