//
//  MaskViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/11/25.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class MaskViewController: UIViewController {
	let scrollView: UIScrollView = UIScrollView()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.initAppearance()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func initAppearance() {
		self.view.backgroundColor = UIColor.black
		self.scrollView.frame = CGRect(x: 0, y: (ScreenHeight - 200) / 2, width: ScreenWidth, height: 200)
		self.scrollView.backgroundColor = UIColor(red: 7 / 255, green: 0, blue: 44 / 255, alpha: 1)
		self.view.addSubview(self.scrollView)

		let waveForm = WaveFormView(frame: CGRect(x: 0, y: 0, width: ScreenWidth * 15, height: 200))
		waveForm.backgroundColor = UIColor.clear
		self.scrollView.addSubview(waveForm)
		self.scrollView.contentSize = CGSize(width: ScreenWidth * 15, height: 200)
	}
}
