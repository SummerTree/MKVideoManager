//
//  SliderViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/11/7.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class SliderViewController: UIViewController {
	let backgroundImageView: UIImageView = UIImageView()
	var slider: CustomSliderView = CustomSliderView(frame: CGRect.zero)

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor(red: 7 / 255, green: 0, blue: 44 / 255, alpha: 1)
		self.initialAppearance()
	}

	fileprivate func initialAppearance() {
		self.view.addSubview(self.slider)
		self.slider.snp.makeConstraints { (maker) in
			maker.center.equalToSuperview()
			maker.leading.equalToSuperview().offset(80)
			maker.height.equalTo(80)
		}
		self.slider.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
		self.slider.minimumValue = 0.0
		self.slider.maximumValue = 15.0
//		self.slider.setMaximumTrackImage(UIImage(named: "icon_select_time_bg"), for: .normal)
		if let colorImage = self.getImageWithColor(color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5), size: CGSize(width: 200, height: 80)), let roundImage = colorImage.isRoundCorner() {
			self.slider.setMinimumTrackImage(roundImage.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)), for: .normal)
		}

		self.slider.setThumbImage(UIImage(named: "rectangle"), for: .normal)
		self.slider.layer.contents = UIImage(named: "icon_select_time_bg")?.cgImage
//		self.slider.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
		self.slider.maximumTrackTintColor = UIColor.clear
		self.slider.trackHeight = 80
		self.slider.layer.cornerRadius = 12
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIView.animate(withDuration: 1.0) {
			self.slider.setValue(15.0, animated: true)
		}

		UIView.animate(withDuration: 1.0,
					   delay: 1.0,
					   options: UIView.AnimationOptions.curveEaseInOut,
					   animations: {
			self.slider.setValue(5.0, animated: true)
		}, completion: nil)
		UIView.animate(withDuration: 1.0,
					   delay: 2.0,
					   options: UIView.AnimationOptions.curveEaseInOut,
					   animations: {
			self.slider.setValue(15.0, animated: true)
		}, completion: nil)
		UIView.animate(withDuration: 1.0,
					   delay: 3.0,
					   options: UIView.AnimationOptions.curveEaseInOut,
					   animations: {
			self.slider.setValue(0.0, animated: true)
		}, completion: nil)
	}

	func getImageWithColor(color: UIColor, size: CGSize) -> UIImage? {
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}

extension UIImage {
	/**
	设置是否是圆角(默认:3.0,图片大小)
	*/
	func isRoundCorner() -> UIImage? {
		return self.isRoundCorner(radius: 12.0, size: self.size)
	}
	/**
	设置是否是圆角
	- parameter radius: 圆角大小
	- parameter size:   size
	- returns: 圆角图片
	*/
	func isRoundCorner(radius: CGFloat, size: CGSize) -> UIImage? {
		let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
		//开始图形上下文
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		//绘制路线
		UIGraphicsGetCurrentContext()!.addPath(UIBezierPath(roundedRect: rect,
															byRoundingCorners: UIRectCorner.allCorners,
															cornerRadii: CGSize(width: radius, height: radius)).cgPath)
		//裁剪
		UIGraphicsGetCurrentContext()!.clip()
		//将原图片画到图形上下文
		self.draw(in: rect)
		UIGraphicsGetCurrentContext()!.drawPath(using: .fillStroke)
		let output = UIGraphicsGetImageFromCurrentImageContext()
		//关闭上下文
		UIGraphicsEndImageContext()
		return output
	}
}
