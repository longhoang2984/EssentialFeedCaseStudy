//
//  RemoteImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 19/11/2022.
//

import Foundation

class RemoteImageCommentsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
