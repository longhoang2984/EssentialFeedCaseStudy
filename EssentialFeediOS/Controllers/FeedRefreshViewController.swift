//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 11/10/2022.
//

import UIKit

class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private var presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    private(set) lazy var view: UIRefreshControl = loadView()
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
