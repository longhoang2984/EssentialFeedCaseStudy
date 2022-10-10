//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Cửu Long Hoàng on 10/10/2022.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer: UIView = UIView()
    public let locationLabel: UILabel = UILabel()
    public let descriptionLabel: UILabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    public var onRetry: (() -> Void)?
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let bt = UIButton()
        bt.addTarget(self, action: #selector(retry), for: .touchUpInside)
        return bt
    }()
    
    @objc private func retry() {
        onRetry?()
    }
}