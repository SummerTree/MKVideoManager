//
//  ScrollNumberViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/15.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation
import DPScrollNumberLabel
import NumberScrollAnimatedView
import JTNumberScrollAnimatedView

class ScrollNumberViewController: UIViewController {
	lazy var numberLabel: DPScrollNumberLabel = DPScrollNumberLabel(number: NSNumber(value: 0), fontSize: 15, rowNumber: 3)
	lazy var numberLabel1: NumberScrollAnimatedView = NumberScrollAnimatedView()
	lazy var numberLabel2: JTNumberScrollAnimatedView = JTNumberScrollAnimatedView()

	@IBOutlet weak var textField: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.numberLabel.frame = CGRect(x: 0, y: 84, width: self.numberLabel.frame.size.width, height: self.numberLabel.frame.size.height)
		self.view.addSubview(self.numberLabel)

		self.view.addSubview(self.numberLabel1)
		self.numberLabel1.frame = CGRect(x: 100, y: 84, width: 51, height: 20)
		self.numberLabel1.backgroundColor = UIColor.green
		self.numberLabel1.font = UIFont.systemFont(ofSize: 18)
		self.numberLabel1.textColor = UIColor.red
		self.numberLabel1.animationDuration = 2
		self.numberLabel1.text = "000"

		self.view.addSubview(self.numberLabel2)
		self.numberLabel2.frame = CGRect(x: 200, y: 84, width: 51, height: 20)
		self.numberLabel2.value = NSNumber(value: 0)
		self.numberLabel2.backgroundColor = UIColor.red
		self.numberLabel2.textColor = UIColor.green
		self.numberLabel2.font = UIFont.systemFont(ofSize: 18)
	}

	@IBAction func startClicked(_ sender: Any) {
		let text = self.textField.text!
		guard let toNumber = Int(text) else {
			return
		}
		self.numberLabel.change(to: NSNumber(value: toNumber), animated: true)
		if toNumber < 50 {
			self.numberLabel1.textColor = UIColor.red
//			self.numberLabel.reloadNumber(UIColor.red)
		} else {
//			self.numberLabel.reloadNumber(UIColor.green)
		}

		self.numberLabel1.text = text
		self.numberLabel1.startAnimation()

		self.numberLabel2.value = NSNumber(value: toNumber)
		self.numberLabel2.startAnimation()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
}
