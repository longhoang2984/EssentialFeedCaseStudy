//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 26/10/2022.
//

import XCTest

struct FeedErrorViewModel {
    var message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

class FeedPresenter {
    let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
    }
}

final class FeedPresenterTests: XCTestCase {

    func test_feed_deliversNoErrorOnLoading() {
        let (sut, spy) = makeSUT()
        
        sut.didStartLoading()
        XCTAssertEqual(spy.messages, [.display(error: nil)])
    }
    
    // MARK: - Helper
    private func makeSUT(url: URL = URL(string: "https://google.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedPresenter(errorView: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(error: String?)
        }
        
        private(set) var messages: [Message] = []
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(error: viewModel.message))
        }
    }
}
