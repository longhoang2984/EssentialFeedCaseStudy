//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Cửu Long Hoàng on 20/11/2022.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR", tableName: "Shared", bundle: Bundle(for: LoadResourcePresenter<Resource, View>.self), comment: "load error message")
    }
    
    public init(
        resourceView: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView,
        mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
