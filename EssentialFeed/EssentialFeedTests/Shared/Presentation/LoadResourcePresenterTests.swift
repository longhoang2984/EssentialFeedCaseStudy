//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 20/11/2022.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartLoading() {
        let (sut, spy) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(spy.messages, [.display(error: nil), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingResource_displaysViewMessageAndStopLoading() {
        let (sut, spy) = makeSUT()
        
        let error = anyNSError()
        sut.didFinishLoading(with: error as Error)
        XCTAssertEqual(spy.messages, [
            .display(error: localized("GENERIC_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingResource_displaysResourceAndStopLoading() {
        let (sut, spy) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(spy.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    // MARK: - Helper
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        url: URL = URL(string: "https://google.com")!,
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: SUT, spy: ViewSpy) {
            let spy = ViewSpy()
            let sut = LoadResourcePresenter(loadingView: spy, resourceView: spy, errorView: spy, mapper: mapper)
            trackForMemoryLeaks(sut, file: file, line: line)
            trackForMemoryLeaks(spy, file: file, line: line)
            return (sut, spy)
        }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, ResourceView {
        typealias ResourceViewModel = String
        enum Message: Hashable {
            case display(error: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages: Set<Message> = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(error: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
    }
    
}
