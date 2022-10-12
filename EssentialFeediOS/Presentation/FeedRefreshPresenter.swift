//
//  FeedRefreshPresenter.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 12/10/2022.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedImageView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var loadingView: FeedLoadingView?
    var feedView: FeedImageView?
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = (try? result.get()) {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
