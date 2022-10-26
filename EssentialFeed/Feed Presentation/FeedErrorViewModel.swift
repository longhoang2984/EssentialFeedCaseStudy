//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

public struct FeedErrorViewModel {
    public var message: String?
    
    static public var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static public func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
