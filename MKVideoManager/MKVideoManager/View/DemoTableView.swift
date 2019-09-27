//
//  DemoTableView.swift
//  MKVideoManager
//
//  Created by holla on 2019/4/11.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

protocol DemoTableViewDelegate: NSObjectProtocol {
	func animationFinished()
}

class DemoTableView: UITableView {
	var activeTweenOperation: PRTweenOperation?
	weak var demoDelegate: DemoTableViewDelegate?

	override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func doAnimationScrollTo(point: CGPoint) {
		let offset = self.contentOffset
		self.activeTweenOperation = PRTweenCGPointLerp.lerp(self, property: "contentOffset", from: offset, to: point, duration: 2, timing: nil, target: self, complete: #selector(finish))
//			PRTweenCGPointLerp.lerp(self, property: "contentOffset", from: offset, to: point, duration: 3)
	}

	@objc func finish() {
		self.demoDelegate?.animationFinished()
	}
}
