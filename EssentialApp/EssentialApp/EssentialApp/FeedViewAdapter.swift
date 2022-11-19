//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 24/10/2022.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

class FeedViewAdapter: NSObject, FeedView {
    
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(view: WeakVirtualProxy(view), imageTransformer: UIImage.init)
            
            return view
        })
    }
    
}
