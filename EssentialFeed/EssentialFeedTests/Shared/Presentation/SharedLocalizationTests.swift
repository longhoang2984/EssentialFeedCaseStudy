//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Cửu Long Hoàng on 21/11/2022.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizationStrings_haveKeysAndValuesForAllSupportLocalization() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(presentationBundle, table)
    }

}
