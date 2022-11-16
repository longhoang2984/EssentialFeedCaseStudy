//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 24/10/2022.
//

import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    var presenter: FeedPresenter?
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoading(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }
}
