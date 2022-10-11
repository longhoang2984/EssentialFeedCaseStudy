//
//  FeedRefreshViewModel.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 12/10/2022.
//

import EssentialFeed

final class FeedRefreshViewModel {
    
    private var feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingChanged: ((Bool) -> Void)?
    var onFeedChanged: (([FeedImage]) -> Void)?
    func loadFeed() {
        onLoadingChanged?(true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = (try? result.get()) {
                self.onFeedChanged?(feed)
            }
            self.onLoadingChanged?(false)
        }
    }
}
