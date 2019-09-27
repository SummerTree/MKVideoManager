//
//  ColorsCollectionCell.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/13.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

class ColorCollectionCell: UICollectionViewCell {
    var normalContentView: UIView?
    var selectedContentView: UIView?
    var contentColor: UIColor?
    var selectedLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }

    func initUI() {
        if self.selectedContentView == nil {
            self.selectedContentView = UIView()
            self.selectedContentView?.backgroundColor = UIColor.black
            self.selectedContentView?.layer.cornerRadius = 16
            self.selectedContentView?.layer.borderColor = UIColor.white.cgColor
            self.selectedContentView?.layer.borderWidth = 2
            self.contentView.addSubview(self.selectedContentView!)
            self.selectedContentView?.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 32, height: 32))
            })
        }

        if self.normalContentView == nil {
            self.normalContentView = UIView()
            self.normalContentView?.backgroundColor = UIColor.white
            self.normalContentView?.layer.cornerRadius = 14
            self.contentView.addSubview(self.normalContentView!)
            self.normalContentView?.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 28, height: 28))
            })
        }
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.selectedContentView?.isHidden = false
            } else {
                self.selectedContentView?.isHidden = true
            }
        }
    }
}
