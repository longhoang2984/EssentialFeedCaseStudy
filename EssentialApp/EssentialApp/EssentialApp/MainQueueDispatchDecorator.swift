//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 24/10/2022.
//

import EssentialFeed

class MainQueueDispatchDecorator<T> {
    
    private let decoratee: T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                return completion(result)
            } else {
                DispatchQueue.main.async {
                    return completion(result)
                }
            }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { result in
            if Thread.isMainThread {
                return completion(result)
            } else {
                DispatchQueue.main.async {
                    return completion(result)
                }
            }
        }
    }
}
