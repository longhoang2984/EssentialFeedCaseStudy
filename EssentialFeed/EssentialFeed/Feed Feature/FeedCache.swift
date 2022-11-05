//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 05/11/2022.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feeds: [FeedImage], completion: @escaping (Result) -> Void)
}
