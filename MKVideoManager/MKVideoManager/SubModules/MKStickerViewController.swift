//
//  MKStickerViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/1/18.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class MKStickerViewController: UIViewController {
	var questionSticker: MKQuestionStickerView!
	var maskView: MKMomentEditMaskView!
	override func viewDidLoad() {
		self.view.backgroundColor = UIColor.gray
		self.setSubViews()
	}

	func setSubViews() {
		questionSticker = MKQuestionStickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: 94))
		self.view.addSubview(questionSticker)
		let stickerWidth: CGFloat = 278
//		let stickerHeight: CGFloat = 114
		questionSticker.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().offset(300)
			make.width.equalTo(stickerWidth)
//			make.height.equalTo(stickerHeight)
		}
		let tapGes = UITapGestureRecognizer(target: self, action: #selector(tap))
		questionSticker.addGestureRecognizer(tapGes)

		maskView = MKMomentEditMaskView(frame: UIScreen.main.bounds)

		maskView.delegate = self
	}

	@objc func tap() {
//		self.animationGroup(with: self.questionSticker)
		questionSticker.alpha = 0
		self.animationAlpha(with: questionSticker, beginTime: 3, duration: 5)
//		questionSticker.snp.updateConstraints { (make) in
//			make.top.equalToSuperview().offset(200)
//		}
//		questionSticker.adjustSendButton(show: true)
//		questionSticker.adjustAnswerTextView("saheighewaghiewuahgiwehagihweaighwigahi")
//
//		self.view.insertSubview(maskView, belowSubview: self.questionSticker)
//		UIView.animate(withDuration: 0.25) {
//			self.maskView.alpha = 1
//			self.questionSticker.sendButton.alpha = 1
//			self.view.layoutIfNeeded()
//		}
	}

	func animationGroup(with view: UIView) {
		let scaleAnimation1: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation1.fromValue = NSNumber(value: 1)
		scaleAnimation1.toValue = NSNumber(value: 1.15)
		scaleAnimation1.beginTime = 0
		scaleAnimation1.duration = 0.2

		let scaleAnimation2: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation2.fromValue = NSNumber(value: 1.15)
		scaleAnimation2.toValue = NSNumber(value: 0.91)
		scaleAnimation2.beginTime = 0.2
		scaleAnimation2.duration = 0.2

		let scaleAnimation3: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation3.fromValue = NSNumber(value: 0.91)
		scaleAnimation3.toValue = NSNumber(value: 1)
		scaleAnimation3.beginTime = 0.4
		scaleAnimation3.duration = 0.1

		let positonAnimation1: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
		let viewCenterX = view.center.x
		let viewCeneerY = view.center.y
		positonAnimation1.values = [
			CGPoint(x: viewCenterX - 8, y: viewCeneerY),
			CGPoint(x: viewCenterX + 8, y: viewCeneerY),
			CGPoint(x: viewCenterX - 6, y: viewCeneerY),
			CGPoint(x: viewCenterX + 6, y: viewCeneerY),
			CGPoint(x: viewCenterX, y: viewCeneerY)
		]
		positonAnimation1.duration = 0.5
		positonAnimation1.beginTime = 1.5

		let positonAnimation2: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
		positonAnimation2.values = [
			CGPoint(x: viewCenterX - 8, y: viewCeneerY),
			CGPoint(x: viewCenterX + 8, y: viewCeneerY),
			CGPoint(x: viewCenterX - 6, y: viewCeneerY),
			CGPoint(x: viewCenterX + 6, y: viewCeneerY),
			CGPoint(x: viewCenterX, y: viewCeneerY)
		]
		positonAnimation2.duration = 0.5
		positonAnimation2.beginTime = 4.5

		let group: CAAnimationGroup = CAAnimationGroup()
		group.animations = [
			scaleAnimation1,
			scaleAnimation2,
			scaleAnimation3,
			positonAnimation1,
			positonAnimation2
		]
		group.duration = 5
		group.isRemovedOnCompletion = true
		group.fillMode = CAMediaTimingFillMode.forwards
		view.layer.add(group, forKey: nil)
	}

	func animationAlpha(with view: UIView, beginTime: CFTimeInterval, duration: CFTimeInterval) {
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.fromValue = 0
		animation.toValue = 1
		animation.duration = 2
		animation.beginTime = 0

		let animation2 = CABasicAnimation(keyPath: "opacity")
		animation2.fromValue = 1
		animation2.toValue = 1
		animation2.duration = 2.5
		animation2.beginTime = 2

		let group: CAAnimationGroup = CAAnimationGroup()
		group.animations = [
			animation,
			animation2
		]
		group.duration = 4.5

		view.layer.add(group, forKey: "view-opacity")
		view.alpha = 0
	}
}

extension MKStickerViewController: MKMomentEditMaskViewDelegate {
	func cancelButtonClicked() {
	}

	func doneButtonClicked() {
	}

	func maskViewTaped() {
		questionSticker.snp.updateConstraints { (make) in
			make.top.equalToSuperview().offset(300)
		}
		questionSticker.adjustSendButton(show: false)
		UIView.animate(withDuration: 0.25, animations: {
			self.maskView.alpha = 0
			self.questionSticker.sendButton.alpha = 0
			self.view.layoutIfNeeded()
		}) { (_) in
			self.maskView.removeFromSuperview()
		}
	}
}
