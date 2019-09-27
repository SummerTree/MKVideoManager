//
//  MKScrollTableViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/4/11.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class MKScrollTableViewController: UIViewController {
	@IBOutlet weak var tableView: DemoTableView!
	let cellHeight: CGFloat = 89
	let optionString: String = "Anyone who saw this moment can pick a question and ask you"
	lazy var datas: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.demoDelegate = self
		self.setupData()
	}

	func setupData() {
		datas.append(self.optionString)
		for index in 0...19 {
			let indexString = "\(index)"
			datas.append(indexString)
		}
		if let random = datas.randomElement(), let randomIndex = datas.firstIndex(of: random) {
			print("randomString: \(random)， randomIndex: \(randomIndex)")
			datas.remove(at: randomIndex)
			datas.insert(random, at: datas.count)
		}
		self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
	}

	@IBAction func startAction(_ sender: Any) {
		let offsetY = self.cellHeight * CGFloat(datas.count - 1)
		self.tableView.doAnimationScrollTo(point: CGPoint(x: 0, y: offsetY))
	}

	@IBAction func stopAction(_ sender: Any) {
		self.datas.removeAll()
		self.setupData()
		self.tableView.reloadData()
	}

	fileprivate func resetDatas() {
		if datas.contains(self.optionString), let optionIndex = datas.firstIndex(of: self.optionString) {
			datas.remove(at: optionIndex)
		}
		if let selectedString: String = datas.last, let _ = datas.first {
//			swap(&datas[], &<#T##b: T##T#>)
			datas.remove(at: datas.count - 1)
			datas.insert(selectedString, at: 0)
			if let random = datas.randomElement(), let randomIndex = datas.firstIndex(of: random) {
				print("randomString: \(random)， randomIndex: \(randomIndex)")
				datas.remove(at: randomIndex)
				datas.insert(random, at: datas.count)
			}
		}

		self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
	}
}

extension MKScrollTableViewController: DemoTableViewDelegate {
	func animationFinished() {
		self.resetDatas()
	}
}

extension MKScrollTableViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datas.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: MKTextCell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! MKTextCell
		cell.contentLabel.text = datas[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.cellHeight
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class MKTextCell: UITableViewCell {
	@IBOutlet weak var contentLabel: UILabel!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func setup() {
	}
}
