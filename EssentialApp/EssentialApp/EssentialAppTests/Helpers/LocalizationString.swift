//
//  LocalizationString.swift
//  EssentialFeediOSTests
//
//  Created by Cửu Long Hoàng on 24/10/2022.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }

}
