//
//  MKAdjustFontViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/1/31.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class MKAdjustFontViewController: UIViewController {
	var textView: UITextView!
	let maxFontSize: CGFloat = 80
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		self.setSubViews()
	}
	
	func setSubViews() {
		textView = UITextView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 300))
		textView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
		textView.delegate = self
		textView.textColor = UIColor.white
		textView.font = UIFont.boldSystemFont(ofSize: maxFontSize)
		textView.textAlignment = .center
		self.view.addSubview(textView)
	}
}

extension MKAdjustFontViewController: UITextViewDelegate {
	func adjustFont() {
		let bestFontSize = UIFont.bestFitFontSize(for: self.textView.text, in: self.textView.bounds, adjustFont: self.textView.font!, maxFontSize: self.maxFontSize)
		print(bestFontSize)
		self.textView.font = UIFont.boldSystemFont(ofSize: bestFontSize)
		self.textView.contentSize = self.textView.bounds.size
	}
	
	internal func textViewDidChange(_ textView: UITextView) {
		textView.flashScrollIndicators()
		self.adjustFont()
	}
	
	internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		return true
	}
}

extension UIFont {
	
	/**
	Will return the best approximated font size which will fit in the bounds.
	If no font with name `fontName` could be found, nil is returned.
	*/
	static func bestFitFontSize(for text: String, in bounds: CGRect, adjustFont: UIFont, maxFontSize: CGFloat) -> CGFloat {
		var bestFitFontSize: CGFloat = maxFontSize // UIKit best renders with factors of 2
		
		let textWidth = text.width(withConstraintedHeight: bounds.height, font: adjustFont)
		let textHeight = text.height(withConstrainedWidth: bounds.width, font: adjustFont)
		
		// Determine the font scaling factor that should allow the string to fit in the given rect
		let scalingFactor = min(bounds.width / textWidth, bounds.height / textHeight)
		
		// Adjust font size
		bestFitFontSize *= scalingFactor
		
		return floor(bestFitFontSize)
	}
	
}

extension String {
	
	func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}
	
	func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}
}





