//
//  FeedRefreshViewModel.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 12/10/2022.
//

import EssentialFeed

final class FeedRefreshViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingChanged: Observer<Bool>?
    var onFeedChanged: Observer<[FeedImage]>?
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
