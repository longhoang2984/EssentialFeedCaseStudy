//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Cửu Long Hoàng on 15/11/2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {

    func test_appLaunch_displayFeedViewController() {
        
        let scene = SceneDelegate()
        scene.window = UIWindow()
        
        scene.configureWindow()
        
        let root = scene.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topViewController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected root view controller is UINavigationController, got \(String(describing: rootNavigation)) instead")
        XCTAssertTrue(topViewController is FeedViewController, "Expected top of UINavigationController is FeedViewController, got \(String(describing: topViewController)) instead")
    }

}
