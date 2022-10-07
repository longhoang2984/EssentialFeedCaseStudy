//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 07/10/2022.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliverEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_overridesPreviouslyInsertedCacheValues()
    
    
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversEmptyOnNonEmptyCache()
    
    func test_storeSideEffects_runSerrially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversFailureOnInsertionError()
    func test_insert_hasNoSideEffectsOnFailure()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnFailure()
}
