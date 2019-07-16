//
//  GoodsTipView.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/15.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation


class GoodsTipView: UIView {
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var renewButton: UIButton!
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initailAppearance()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initailAppearance()
	}

	func initailAppearance() {
	}

	@IBAction func renewClicked(_ sender: Any) {
		//ss
	}
}

class GoodsTimeTipView: UIView {
	
	@IBOutlet weak var timeLabel: UILabel!
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initailAppearance()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initailAppearance()
	}

	func initailAppearance() {
	}
}

import DPScrollNumberLabel
class GoodsNumberTipView: UIView {
	@IBOutlet weak var numberView: DPScrollNumberLabel!
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initailAppearance()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initailAppearance()
	}

	func initailAppearance() {
	}
}
