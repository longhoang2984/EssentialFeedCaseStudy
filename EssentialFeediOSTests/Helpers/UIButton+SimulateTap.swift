//
//  UIButton+SimulateTap.swift
//  EssentialFeediOSTests
//
//  Created by Cửu Long Hoàng on 24/10/2022.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

