//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

public final class FeedPresenter {
    static public var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Feed title view")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
