//
//  CustomSliderView.swift
//  MKVideoManager
//
//  Created by holla on 2019/11/7.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class CustomSliderView: UISlider {
	/// slider track高度设置
	@IBInspectable var trackHeight: CGFloat = 2

	// 设置trackView响应的扩大范围
	var trackInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: -20)

	private var lastBounds: CGRect = CGRect.zero

	override func trackRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
	}

	override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
		self.lastBounds = rect
		return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
	}

	// 重写以扩大trackImage响应范围
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		var result: UIView? = super.hitTest(point, with: event)
		if result != self {
			if point.x >= 0 && point.x < self.bounds.width && point.y >= trackInsets.top && point.y <= (self.bounds.height - trackInsets.bottom) {
				result = self
			}
		}
		return result
	}

	// 重写以扩大trackImage响应范围
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		var result: Bool = super.point(inside: point, with: event)
		if !result {
			if point.x >= (lastBounds.origin.x + trackInsets.left) && point.x <= (lastBounds.origin.x + lastBounds.width - trackInsets.right) && point.y >= trackInsets.top && point.y <= (self.bounds.height - trackInsets.bottom) {
				result = true
			}
		}
		return result
	}
}
