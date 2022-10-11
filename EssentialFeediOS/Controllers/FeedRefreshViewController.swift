//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 11/10/2022.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewModel {
    
    private var feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case failed
    }
    
    private var state: State = .pending {
        didSet {
            onStateChanged?(self)
        }
    }
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .pending, .loaded, .failed: return false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed): return feed
        case .pending, .loading, .failed: return nil
        }
    }
    
    var onStateChanged: ((FeedRefreshViewModel) -> Void)?
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = (try? result.get()) {
                self.state = .loaded(feed)
            } else {
                self.state = .failed
            }
        }
    }
}

class FeedRefreshViewController: NSObject {
    
    private var viewModel: FeedRefreshViewModel
    
    init(feedLoader: FeedLoader) {
        self.viewModel = FeedRefreshViewModel(feedLoader: feedLoader)
    }
    
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        bind(refreshControl)
        return refreshControl
    }()
    
    var onRefresh: (([FeedImage]) -> Void)?
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func bind(_ view: UIRefreshControl) {
        viewModel.onStateChanged = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
            
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}
