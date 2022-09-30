//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 27/09/2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
