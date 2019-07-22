//
//  MKCoverCollectionCell.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/16.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

import UIKit

class MKCoverCollectionCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }

    func initUI() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: MKVideoCoverViewController.itemWidth, height: MKVideoCoverViewController.itemHeight))
        self.contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 1
        imageView.layer.masksToBounds = true
    }
}
