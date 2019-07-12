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
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	@IBAction func popTip1Clicked(_ sender: UIButton) {
		let popTip: PopTip = PopTip()
		popTip.show(text: "Hi, text", direction: .down, maxWidth: 200, in: self.view, from: sender.frame)
		popTip.actionAnimation = .bounce(6)
		popTip.padding = 20
		self.popTip1 = popTip
	}
	@IBAction func popTip2Clicked(_ sender: UIButton) {
		let popTip: PopTip = PopTip()
		popTip.show(text: "Hi, text", direction: .left, maxWidth: 200, in: self.view, from: sender.frame)
		popTip.bubbleColor = UIColor.cyan
		self.popTip2 = popTip
	}
	@IBAction func popTip3Clicked(_ sender: UIButton) {
		let popTip: PopTip = PopTip()
		popTip.show(text: "Hi, text", direction: .right, maxWidth: 200, in: self.view, from: sender.frame)
		popTip.shouldDismissOnTapOutside = false
		popTip.offset = 10
		self.popTip3 = popTip
	}

	@IBAction func popTip4Clicked(_ sender: UIButton) {
		let popTip: PopTip = PopTip()
		popTip.show(text: "Hi, text", direction: .up, maxWidth: 200, in: self.view, from: sender.frame)
//		popTip.shouldDismissOnSwipeOutside = true
		self.popTip4 = popTip
	}
}
