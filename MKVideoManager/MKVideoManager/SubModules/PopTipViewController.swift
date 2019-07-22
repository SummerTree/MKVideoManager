//
//  PopTipViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/12.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation
import AMPopTip

class PopTipViewController: UIViewController {
	var popTip1: PopTip?
	var popTip2: PopTip?
	var popTip3: PopTip?
	var popTip4: PopTip?
	var tipView: GoodsTipView?
	var goodTimeView: GoodsTimeTipView?
	var goodsNumberView: GoodsNumberTipView?
	var lastTime: TimeInterval = 3600.0
	var lastNumber: Int = 100

	override func viewDidLoad() {
		super.viewDidLoad()
		self.initailAppearance()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func initailAppearance() {
		let tipView = Bundle.main.loadNibNamed("GoodTipView", owner: nil, options: nil)?.first as! GoodsTipView
		let timeView = Bundle.main.loadNibNamed("GoodTimeTipView", owner: nil, options: nil)?.first as! GoodsTimeTipView
		let numberView = Bundle.main.loadNibNamed("GoodNumberView", owner: nil, options: nil)?.first as! GoodsNumberTipView
		self.tipView = tipView
		self.goodTimeView = timeView
		self.goodsNumberView = numberView
	}

	@IBAction func popTip1Clicked(_ sender: UIButton) {
		if let tip = self.popTip1, tip.isVisible {
			return
		}
		let popTip: PopTip = PopTip()
		self.setupPoptip(popTip: popTip)
		popTip.cornerRadius = 12
		popTip.show(customView: self.tipView!, direction: .up, in: self.view, from: sender.frame)
		self.popTip1 = popTip
	}
	@IBAction func popTip2Clicked(_ sender: UIButton) {
		if let tip = self.popTip2, tip.isVisible {
			return
		}
		let popTip: PopTip = PopTip()
		self.setupPoptip(popTip: popTip)
		popTip.show(text: "Hi, text", direction: .left, maxWidth: 200, in: self.view, from: sender.frame)
		self.popTip2 = popTip
	}
	@IBAction func popTip3Clicked(_ sender: UIButton) {
		if let tip = self.popTip3, tip.isVisible {
			return
		}
		let popTip: PopTip = PopTip()
		self.setupPoptip(popTip: popTip)
		popTip.show(customView: self.goodsNumberView!, direction: .up, in: self.view, from: sender.frame)
		self.popTip3 = popTip
	}

	@IBAction func popTip4Clicked(_ sender: UIButton) {
		if let tip = self.popTip4, tip.isVisible {
			return
		}
		let popTip: PopTip = PopTip()
		self.setupPoptip(popTip: popTip)
		popTip.show(customView: self.goodTimeView!, direction: .up, in: self.view, from: sender.frame)
		self.popTip4 = popTip
	}

	private func setupPoptip(popTip: PopTip) {
		popTip.padding = 0
		popTip.cornerRadius = 3
		popTip.offset = 14
		popTip.arrowSize = CGSize(width: 14, height: 8)
		popTip.bubbleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
		popTip.shouldDismissOnTapOutside = false
	}

	@IBAction func changeClicked(_ sender: Any) {
		self.lastTime -= 1
		self.goodTimeView?.reloadTip(lastTime: self.lastTime)
		self.lastNumber += 100
		self.goodsNumberView?.reloadTip(lastCount: self.lastNumber)
	}
	@IBAction func changePop3Clicked(_ sender: Any) {
		self.lastNumber -= 1
		self.goodsNumberView?.reloadTip(lastCount: self.lastNumber)
	}
}
