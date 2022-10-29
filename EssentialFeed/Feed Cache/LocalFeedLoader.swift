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
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
}
 
extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(feeds, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feeds: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feeds.toLocalFeed(), timestamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
    
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate):
                completion(.success(cache.feed.toModels()))
            case let .failure(error):
                completion(.failure(error))
            case .success:
                completion(.success([]))
            }
        }
    }
    
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping ((ValidationResult) -> Void)) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in completion(.success(())) }
            
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate):
                self.store.deleteCachedFeed { _ in completion(.success(())) }
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == FeedImage {
    
    func toLocalFeed() -> [LocalFeedImage] {
        return map({ return LocalFeedImage(id: $0.id, description:
                                            $0.description,
                                          location: $0.location,
                                          url: $0.url) })
    }
    
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
