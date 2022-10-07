//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 06/10/2022.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpects {
    
    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreArtifacts()
    }
    
    func test_retrieve_deliverEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
        
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        let storeURL = URL(string: "invalid://invalid-url")!
        let sut = makeSUT(storeURL: storeURL)

        assertThatInsertDeliversFailureOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let storeURL = URL(string: "invalid://invalid-url")!
        let sut = makeSUT(storeURL: storeURL)
        assertThatInsertHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversEmptyOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noPermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noPermissionURL)

        assertThatDeleteDeliversFailureOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnFailure() {
        let noPermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noPermissionURL)

        assertThatDeleteHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_storeSideEffects_runSerrially() {
        let sut = makeSUT()
        assertThatSideEffectsRunSerrially(on: sut)
    }
    
    // MARK: - Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let store = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(store, file: file, line: line)
        return store
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreArtifacts() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
