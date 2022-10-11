//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 11/10/2022.
//

import UIKit
import EssentialFeed

class FeedRefreshViewController: NSObject {
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    var onRefresh: (([FeedImage]) -> Void)?
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = (try? result.get()) {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
