//
//  MKPlaceholderTextView.swift
//  MKVideoManager
//
//  Created by holla on 2019/1/18.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//
import Foundation
import UIKit

protocol MKPlaceholderTextViewDelegate {
	func placeholderTextViewDidChangeText(_ text:String)
	func placeholderTextViewDidEndEditing(_ text:String)
}

final class MKPlaceholderTextView: UITextView {
	
	var notifier:MKPlaceholderTextViewDelegate?
	
	var placeholder: String? {
		didSet {
			placeholderLabel?.text = placeholder
		}
	}
	var placeholderColor = UIColor.lightGray {
		didSet {
			placeholderLabel?.textColor = placeholderColor
		}
	}
	var placeholderFont = UIFont.systemFont(ofSize: 14.0) {
		didSet {
			placeholderLabel?.font = placeholderFont
		}
	}
	
	fileprivate var placeholderLabel: UILabel?
	
	// MARK: - LifeCycle
	
//	init() {
//		super.init(frame: CGRect.zero, textContainer: nil)
//		awakeFromNib()
//	}
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		self.customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.customInit()
	}
	
	func customInit() {
		
		self.delegate = self
		NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeHandler(notification:)), name: UITextView.textDidChangeNotification, object: nil)
		
		placeholderLabel = UILabel()
		placeholderLabel?.textColor = placeholderColor
		placeholderLabel?.text = placeholder
		placeholderLabel?.textAlignment = .left
		placeholderLabel?.numberOfLines = 0
	}
	
//	override func awakeFromNib() {
//		super.awakeFromNib()
//
//		self.delegate = self
//		NotificationCenter.default.addObserver(self, selector: #selector(MKPlaceholderTextView.textDidChangeHandler(notification:)), name: .UITextViewTextDidChange, object: nil)
//
//		placeholderLabel = UILabel()
//		placeholderLabel?.textColor = placeholderColor
//		placeholderLabel?.text = placeholder
//		placeholderLabel?.textAlignment = .left
//		placeholderLabel?.numberOfLines = 0
//	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		placeholderLabel?.font = placeholderFont
		
		var height:CGFloat = placeholderFont.lineHeight
		if let data = placeholderLabel?.text {
			
			let expectedDefaultWidth:CGFloat = bounds.size.width
			let fontSize:CGFloat = placeholderFont.pointSize
			
			let textView = UITextView()
			textView.text = data
			textView.font = UIFont.systemFont(ofSize: fontSize)
			let sizeForTextView = textView.sizeThatFits(CGSize(width: expectedDefaultWidth,
															   height: CGFloat.greatestFiniteMagnitude))
			let expectedTextViewHeight = sizeForTextView.height
			
			if expectedTextViewHeight > height {
				height = expectedTextViewHeight
			}
		}
		let xRatio: CGFloat = 5
		let holderWidth: CGFloat = bounds.size.width - 16
		let yRatio: CGFloat = 0
		
		placeholderLabel?.frame = CGRect(x: xRatio, y: yRatio, width: holderWidth, height: height)
		
		if text.isEmpty {
			addSubview(placeholderLabel!)
			bringSubviewToFront(placeholderLabel!)
		} else {
			placeholderLabel?.removeFromSuperview()
		}
	}
	
	@objc func textDidChangeHandler(notification: Notification) {
		layoutSubviews()
	}
	
}

extension MKPlaceholderTextView : UITextViewDelegate {
	// MARK: - UITextViewDelegate
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if(text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
		notifier?.placeholderTextViewDidChangeText(textView.text)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		notifier?.placeholderTextViewDidEndEditing(textView.text)
	}
}
