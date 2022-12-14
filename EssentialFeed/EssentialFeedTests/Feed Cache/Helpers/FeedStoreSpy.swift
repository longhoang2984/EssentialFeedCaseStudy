//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 04/10/2022.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case inert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completionWithDeletionError(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completionWithInsertionError(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completionWithSuccessfulDeletion(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ feeds: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.inert(feeds, timestamp))
    }
    
    func completionWithSuccessfulInsertion(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completionWithRetrievalError(_ error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completionRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completionRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CacheFeed(feed: feed, timestamp: timestamp)))
    }
    
}
