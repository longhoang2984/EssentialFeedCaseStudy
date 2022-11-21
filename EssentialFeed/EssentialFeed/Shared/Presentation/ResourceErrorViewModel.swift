//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 27/10/2022.
//

public struct ResourceErrorViewModel {
    public var message: String?
    
    static public var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static public func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
