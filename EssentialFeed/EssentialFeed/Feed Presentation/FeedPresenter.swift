//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    let loadingView: ResourceLoadingView
    let feedView: FeedView
    let errorView: ResourceErrorView
    
    static public var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Feed title view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR", tableName: "Shared", bundle: Bundle(for: FeedPresenter.self), comment: "Feed load error")
    }
    
    public init(loadingView: ResourceLoadingView, feedView: FeedView, errorView: ResourceErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
