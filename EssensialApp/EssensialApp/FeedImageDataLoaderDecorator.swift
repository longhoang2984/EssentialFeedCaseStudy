//
//  FeedImageDataLoaderDecorator.swift
//  EssensialApp
//
//  Created by Cửu Long Hoàng on 06/11/2022.
//

import EssentialFeed

public class FeedImageDataLoaderDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoreResult(data, url: url)
                return data
            })
        }
    }
}

private extension FeedImageDataCache {
    func saveIgnoreResult(_ data: Data, url: URL) {
        save(data, for: url) { _ in }
    }
}
