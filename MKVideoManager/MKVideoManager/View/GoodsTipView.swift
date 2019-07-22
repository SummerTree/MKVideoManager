//
//  GoodsTipView.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/15.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

typealias OperationHandler = () -> Void
class GoodsTipView: UIView {
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var renewButton: UIButton!
	var renewHandler: OperationHandler?

	override func awakeFromNib() {
		super.awakeFromNib()
		self.initailAppearance()
	}

	func initailAppearance() {
		self.renewButton.layer.cornerRadius = 20
		self.renewButton.layer.masksToBounds = true
	}

	@IBAction func renewClicked(_ sender: Any) {
		//ss
		self.renewHandler?()
	}
}

class GoodsTimeTipView: UIView {
	@IBOutlet weak var timeLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		self.initailAppearance()
	}

	func initailAppearance() {
	}

	func reloadTip(lastTime: TimeInterval) {
		var lastSeconds: Int = Int(lastTime)
		if lastSeconds > 3600 {
			lastSeconds = 3600
		}
		let (_, m, s) = secondsToHoursMinutesSeconds(seconds: lastSeconds)
		let minutes = self.getStringFrom(seconds: m)
		let seconds = self.getStringFrom(seconds: s)
		self.timeLabel.text = minutes + ":" + seconds
		if lastSeconds > 600 {
			self.timeLabel.textColor = UIColor(red: 255 / 255, green: 252 / 255, blue: 1 / 255, alpha: 1)
		} else {
			self.timeLabel.textColor = UIColor(red: 255 / 255, green: 111 / 255, blue: 111 / 255, alpha: 1)
		}
	}

	// 秒转化为 时分秒
	// swiftlint:disable:next large_tuple
	func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
		let h = seconds / 3600
		let m = (seconds % 3600) / 60
		let s = (seconds % 3600) % 60
		return (h, m, s)
	}

	func getStringFrom(seconds: Int) -> String {
		return seconds < 10 ? "0\(seconds)" : "\(seconds)"
	}
}

import DPScrollNumberLabel
class GoodsNumberTipView: UIView {
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var timesLabel: UILabel!
	@IBOutlet weak var stackView: UIStackView!
	lazy var numberView: DPScrollNumberLabel = DPScrollNumberLabel(number: NSNumber(value: 100), font: UIFont.systemFont(ofSize: 17, weight: .semibold), textColor: UIColor(red: 255 / 255, green: 252 / 255, blue: 1 / 255, alpha: 1), rowNumber: 3)

	@IBOutlet weak var numberLabelWidth: NSLayoutConstraint!

	deinit {
		self.numberView.removeObserver(self, forKeyPath: "frame")
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.initailAppearance()
	}

	func initailAppearance() {
		self.numberLabel.textColor = UIColor.clear
		self.numberView.frame = CGRect(x: 0, y: 0, width: self.numberView.frame.size.width, height: self.numberView.frame.size.height)
		self.numberLabelWidth.constant = self.numberView.frame.size.width
		self.numberLabel.addSubview(self.numberView)
		self.numberView.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
	}

	func reloadTip(lastCount: Int) {
		let lightOrange = UIColor(red: 255 / 255, green: 252 / 255, blue: 1 / 255, alpha: 1)
		let lightRed = UIColor(red: 255 / 255, green: 111 / 255, blue: 111 / 255, alpha: 1)
		self.numberView.change(to: NSNumber(value: lastCount), animated: false)
		if lastCount > 10 {
			self.numberView.updateNumber(lightOrange)
			self.timesLabel.textColor = lightOrange
		} else {
			self.numberView.updateNumber(lightRed)
			self.timesLabel.textColor = lightRed
		}
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		self.numberLabelWidth.constant = self.numberView.frame.size.width
		UIView.animate(withDuration: 0.2) {
			self.stackView.layoutIfNeeded()
		}
	}
}
