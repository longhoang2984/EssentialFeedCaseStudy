//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 10/10/2022.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var feedImageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var feedImageRetryButton: UIButton!
    
    public var onRetry: (() -> Void)?
    
    @IBAction private func retry() {
        onRetry?()
    }
}
