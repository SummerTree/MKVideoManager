//
//  MKScrollTextViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/4/11.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation


class MKScrollTextViewController: UIViewController {
	@IBOutlet weak var scrollView: UIScrollView!
	let cellHeight: CGFloat = 89
	let optionString: String = "Anyone who saw this moment can pick a question and ask you"
	var datas: [String] = []
	var labels: [UILabel] = []
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setupData()
	}
	
	func setupData() {
		for index in 0...19 {
			datas.append(optionString)
			let offsetY = self.cellHeight * CGFloat(index)
			let contentLabel: UILabel = UILabel.init(frame: CGRect.init(x: 0, y: offsetY, width: 321, height: self.cellHeight))
			contentLabel.text = optionString
			contentLabel.numberOfLines = 2
			contentLabel.textColor = UIColor.white
			contentLabel.textAlignment = .center
			contentLabel.backgroundColor = UIColor.clear
			self.scrollView.addSubview(contentLabel)
			
			labels.append(contentLabel)
		}
		let height = self.cellHeight * CGFloat(datas.count)
		self.scrollView.contentSize = CGSize.init(width: 321, height: height)
	}
	
	@IBAction func startAction(_ sender: Any) {
		let offsetY = self.cellHeight * CGFloat(datas.count - 1)
		UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: {
			self.scrollView.contentOffset = CGPoint.init(x: 0, y: offsetY)
		}) { (x) in
			
		}
	}
	@IBAction func stopAction(_ sender: Any) {
		
		UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: {
			self.scrollView.contentOffset = CGPoint.zero
		}) { (x) in
			
		}
	}
}
