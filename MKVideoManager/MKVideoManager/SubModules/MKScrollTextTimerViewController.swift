//
//  MKScrollTextTimerViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/4/11.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class MKScrollTextTimerViewController: UIViewController {
	@IBOutlet weak var textScrollView: MKTextScrollView!
	let cellHeight: CGFloat = 89
	let optionString: String = "Anyone who saw this moment can pick a question and ask you"
	var datas: [String] = []
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupData()
		self.setup()
	}
	
	fileprivate func setup() {
		self.textScrollView.dataSource = self
		self.textScrollView.setTableViewColor()
	}
	
	func setupData() {
		for _ in 0...19 {
			datas.append(optionString)
		}
	}
	
	@IBAction func startAction(_ sender: Any) {
		self.textScrollView.startScroll()
	}
	
	@IBAction func stopAction(_ sender: Any) {
		
	}
	
	
}

extension MKScrollTextTimerViewController: MKTextScrollViewDataSource {
	func sourceData() -> [String]? {
		return datas
	}
	
	func heightForRow(row: Int) -> CGFloat {
		return self.cellHeight
	}
	
	
}
