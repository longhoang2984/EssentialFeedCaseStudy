//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 11/10/2022.
//

import UIKit
import EssentialFeediOS
import EssentialFeed
import Combine

public final class FeedUIComposer {
    
    private init() { }
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: { feedLoader().dispatchOnMainQueue() }
        )
        
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { imageLoader($0) }),
            loadingView: WeakVirtualProxy(feedController),
            errorView: WeakVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = title
        feedController.delegate = delegate
        return feedController
    }
}
