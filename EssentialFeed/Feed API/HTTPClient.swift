//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 30/09/2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to despatch to approriate threads, if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
