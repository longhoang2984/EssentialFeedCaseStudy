//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Cửu Long Hoàng on 13/11/2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
                window = UIWindow(windowScene: windowScene)
                
                let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!

                let client = makeRemoteClient()
                let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
                let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathExtension("feed-store.sqlite")
        
        #if DEBUG
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        #endif
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        let controller = FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader)))
        
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteClient() -> HTTPClient {
        #if DEBUG
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        #endif
        
        return URLSessionHTTPClient(session: .init(configuration: .ephemeral))
        
    }
}

#if DEBUG
private class AlwaysFailingHTTPClient: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "offline", code: 0)))
        return Task()
    }
}
#endif

