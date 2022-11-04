//
//  FeedLoaderWithFallbackComposite.swift
//  EssensialApp
//
//  Created by Cửu Long Hoàng on 04/11/2022.
//

import Foundation
import EssentialFeed

public class FeedLoaderWithFallbackComposite {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
