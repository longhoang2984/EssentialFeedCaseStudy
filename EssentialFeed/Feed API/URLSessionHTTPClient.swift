//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 01/10/2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    private struct UnexpectedValuesRepresentation: Error { }
    
    public init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failed(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failed(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
