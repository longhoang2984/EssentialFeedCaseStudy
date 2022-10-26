//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 26/10/2022.
//

import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedErrorViewModel {
    var message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

class FeedPresenter {
    let loadingView: FeedLoadingView
    let errorView: FeedErrorView
    
    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_feed_deliversNoErrorOnLoading() {
        let (sut, spy) = makeSUT()
        
        sut.didStartLoading()
        XCTAssertEqual(spy.messages, [.display(error: nil), .display(isLoading: true)])
    }
    
    // MARK: - Helper
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedPresenter(loadingView: spy, errorView: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView {
        enum Message: Equatable {
            case display(error: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages: [Message] = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(error: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}
