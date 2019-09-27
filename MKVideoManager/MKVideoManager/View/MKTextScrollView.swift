//
//  MKTextScrollView.swift
//  MKVideoManager
//
//  Created by holla on 2019/4/11.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

protocol MKTextScrollViewDataSource: NSObjectProtocol {
	func sourceData() -> [String]?
	func heightForRow(row: Int) -> CGFloat
}

class MKTextScrollView: UIView {
	var tableView: UITableView!
	var timer: Timer?
	let timeInterval: TimeInterval = 1 / 60
	var offsetY: CGFloat = 0
	weak var dataSource: MKTextScrollViewDataSource?
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setupUI()
	}

	fileprivate func setupUI() {
		self.tableView = UITableView(frame: CGRect.zero, style: .plain)
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.isScrollEnabled = false
		self.tableView.register(MKTextScrollCell.self, forCellReuseIdentifier: "MKTextScrollCell")
		self.addSubview(self.tableView)
		self.tableView.snp.makeConstraints { (make) in
			make.edges.equalTo(self).inset(UIEdgeInsets.zero)
		}
	}

	func setTableViewColor() {
		self.tableView.backgroundColor = UIColor.clear
		self.tableView.separatorColor = UIColor.clear
	}

	func startScroll() {
		offsetY = 0
		timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true, block: { (_) in
			self.offsetY += CGFloat(self.timeInterval) * 100
			self.tableView.setContentOffset(CGPoint(x: 0, y: self.offsetY), animated: false)
		})
	}

	func animateScrollView(duration: Double, to newBounds: CGRect) {
		let animation = CABasicAnimation(keyPath: "bounds")
		animation.duration = duration
		animation.fromValue = tableView.bounds
		animation.toValue = newBounds
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		tableView.layer.add(animation, forKey: nil)
		tableView.bounds = newBounds
	}
}

extension MKTextScrollView: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource?.sourceData()?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: MKTextScrollCell = tableView.dequeueReusableCell(withIdentifier: "MKTextScrollCell", for: indexPath) as! MKTextScrollCell
		guard let datas = self.dataSource?.sourceData() else {
			return MKTextScrollCell()
		}
		cell.textLabel?.text = datas[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.dataSource?.heightForRow(row: indexPath.row) ?? .leastNonzeroMagnitude
	}
}

class MKTextScrollCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	fileprivate func setup() {
		self.selectionStyle = .none
		self.backgroundColor = UIColor.clear
		self.contentView.backgroundColor = UIColor.clear
		self.textLabel?.textColor = UIColor.black
		self.textLabel?.textAlignment = .center
		self.textLabel?.font = UIFont.systemFont(ofSize: 15)
		self.textLabel?.numberOfLines = 2
	}
}
