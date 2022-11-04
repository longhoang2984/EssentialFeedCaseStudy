//
//  FeedCacheTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 05/10/2022.
//

import Foundation
import EssentialFeed

func uniqueFeed() -> FeedImage {
    return FeedImage(id: UUID(), description: "desc", location: "location", imageURL: anyURL())
}

func uniqueFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueFeed(), uniqueFeed()]
    let local = items.map({ return LocalFeedImage(id: $0.id,
                                                  description: $0.description,
                                                  location: $0.location,
                                                  url: $0.url) })
    return (items, local)
}


extension Date {
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return add(days: -feedCacheMaxAgeInDays)
    }
    
    private func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func add(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
