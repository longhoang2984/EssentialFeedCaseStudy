//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 07/10/2022.
//

import CoreData

@objc(ManagedFeedImage)
final class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map({ local in
            let feed = ManagedFeedImage(context: context)
            feed.id = local.id
            feed.imageDescription = local.description
            feed.location = local.location
            feed.url = local.url
            return feed
        }))
    }
}
