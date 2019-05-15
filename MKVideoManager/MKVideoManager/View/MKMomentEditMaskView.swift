//
//  MKMomentEditMaskView.swift
//  MKVideoManager
//
//  Created by holla on 2019/1/19.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

protocol MKMomentEditMaskViewDelegate: NSObjectProtocol {
	func cancelButtonClicked()
	func doneButtonClicked()
	func maskViewTaped()
}

class MKMomentEditMaskView: UIView {
	
	weak var delegate: MKMomentEditMaskViewDelegate?
	fileprivate var cancelButton: UIButton!
	fileprivate var doneButton: UIButton!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.customInit()
	}
	
	func customInit() {
		self.alpha = 0
		self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
		self.setSubView()
		self.setBaseData()
	}
	
	func setSubView() {
		cancelButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
		self.addSubview(cancelButton)
		
		doneButton = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.width - 72, y: 0, width: 72, height: 80))
		self.addSubview(doneButton)
		
		let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tap))
		self.addGestureRecognizer(tapGes)
	}
	
	func setBaseData() {
		cancelButton.setTitle("CANCEL", for: .normal)
		cancelButton.adjustsImageWhenHighlighted = true
		cancelButton.setTitleColor(UIColor.white, for: .normal)
		doneButton.setTitle("DONE", for: .normal)
		doneButton.adjustsImageWhenHighlighted = true
		doneButton.setTitleColor(UIColor.white, for: .normal)
	}
	
	//MAKR: action
	@objc func tap() {
		self.delegate?.maskViewTaped()
	}
	
}
