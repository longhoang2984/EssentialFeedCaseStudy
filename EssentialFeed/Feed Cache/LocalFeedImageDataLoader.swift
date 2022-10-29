//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 29/10/2022.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}
 
extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, SaveError>
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result
                .mapError({ _ in SaveError.failed }))
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    
    private final class Task: FeedImageDataLoaderTask {
        
        private var completion: ((LoadResult) -> Void)?
        
        init(completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError({ _ in LoadError.failed })
                .flatMap { data in data.map { .success($0) } ?? .failure(LoadError.notFound) })
        }
        
        return task
    }
}
