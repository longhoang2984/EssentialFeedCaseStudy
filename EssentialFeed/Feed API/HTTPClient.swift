//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 30/09/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failed(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
