//
//  MKRefreshCollectionViewCell.swift
//  MKVideoManager
//
//  Created by holla on 2018/12/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

class MKRefreshCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setSubViews()
    }

    func setSubViews() {
        imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 60)))
        imageView.backgroundColor = UIColor.purple
        self.contentView.addSubview(imageView)
    }
}
