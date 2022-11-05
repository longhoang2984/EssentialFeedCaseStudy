//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 06/11/2022.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
