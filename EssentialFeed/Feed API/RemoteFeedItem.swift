//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 03/10/2022.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    internal var item: FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}
