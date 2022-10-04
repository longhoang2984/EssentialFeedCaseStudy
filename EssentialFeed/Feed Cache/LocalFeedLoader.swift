//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 03/10/2022.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    public typealias SaveResult = Error?
    public typealias LoadResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.cache(feeds, completion: completion)
            }
        }
    }
    
    private func cache(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feeds.toLocalFeed(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: completion)
    }
}

private extension Array where Element == FeedImage {
    
    func toLocalFeed() -> [LocalFeedImage] {
        return map({ return LocalFeedImage(id: $0.id, description:
                                            $0.description,
                                          location: $0.location,
                                          imageURL: $0.imageURL) })
    }
    
}
