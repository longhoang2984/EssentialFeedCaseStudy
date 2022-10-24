//
//  UIRefreshControler+Simulations.swift
//  EssentialFeediOSTests
//
//  Created by Cửu Long Hoàng on 24/10/2022.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
