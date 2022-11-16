//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 12/10/2022.
//

import EssentialFeed

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
