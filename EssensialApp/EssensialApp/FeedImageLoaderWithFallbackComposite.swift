//
//  FeedImageLoaderWithFallbackComposite.swift
//  EssensialApp
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import Foundation
import EssentialFeed

public class FeedImageLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapper?.cancel()
        }
    }
    
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        
        task.wrapper = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}
