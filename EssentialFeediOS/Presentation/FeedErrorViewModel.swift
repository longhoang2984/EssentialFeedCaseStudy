//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 26/10/2022.
//

import Foundation

struct FeedErrorViewModel {
    var message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
