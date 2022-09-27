//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 27/09/2022.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoad {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
