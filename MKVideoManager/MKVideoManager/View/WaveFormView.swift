//
//  WaveFormView.swift
//  MKVideoManager
//
//  Created by holla on 2019/11/25.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class WaveFormView: UIView {
	let barWidth: CGFloat = 4.0
	let space: CGFloat = 4.0
	let radius: CGFloat = 2.0
	let heights: [CGFloat] = [53.1, 39.0, 46.8, 64.0, 53.1, 34.3, 21.9, 14.0]

	var trimGradientLayer = CAGradientLayer()
	var selectGradientLayer = CAGradientLayer()
	var normalGradientLayer = CAGradientLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}

	private func setupView() {
		normalGradientLayer.colors = [UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0).cgColor,
									  UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0).cgColor]
		normalGradientLayer.locations = [0.6, 1.0]
		self.layer.addSublayer(normalGradientLayer)
		selectGradientLayer.colors = [UIColor(red: 194 / 255, green: 21 / 255, blue: 0 / 255, alpha: 1.0).cgColor,
									  UIColor(red: 255 / 255, green: 197 / 255, blue: 0 / 255, alpha: 1.0).cgColor]
		selectGradientLayer.locations = [0.6, 1.0]
		self.layer.addSublayer(selectGradientLayer)
		trimGradientLayer.colors = [UIColor(red: 52 / 255, green: 232 / 255, blue: 158 / 255, alpha: 1.0).cgColor,
									 UIColor(red: 15 / 255, green: 52 / 255, blue: 67 / 255, alpha: 1.0).cgColor]
		trimGradientLayer.locations = [0.6, 1.0]
		self.layer.addSublayer(trimGradientLayer)

		self.setupOriginView()
	}

	func setupOriginView() {
		let itemCount: Int = Int(bounds.width / 8)
		let path: UIBezierPath = UIBezierPath()
		for i in 0..<itemCount {
			let x: CGFloat = CGFloat(i) * (barWidth + space) + space
			let index: Int = i % heights.count
			let height: CGFloat = heights[index]
			let y: CGFloat = (bounds.height - height) / 2
			let bar = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height), cornerRadius: 2.0)
			path.append(bar)
		}
		let pathLayer: CAShapeLayer = CAShapeLayer()
		pathLayer.path = path.cgPath

		normalGradientLayer.frame = bounds
		normalGradientLayer.mask = pathLayer

		let selectLayer: CAShapeLayer = CAShapeLayer()
		selectLayer.path = path.cgPath
		selectGradientLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
		selectGradientLayer.mask = selectLayer

		let trimLayer: CAShapeLayer = CAShapeLayer()
		trimLayer.path = path.cgPath
		trimGradientLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
		trimGradientLayer.mask = trimLayer
	}

	func startAnimation() {
		selectGradientLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth / 3, height: bounds.height)
		trimGradientLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth / 3, height: bounds.height)
	}
}
