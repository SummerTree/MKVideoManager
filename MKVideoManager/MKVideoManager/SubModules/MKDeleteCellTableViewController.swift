//
//  MKDeleteCellTableViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/4/25.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class MKDeleteCellTableViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	var dataSource: [String] = Array.init(repeating: "ssssgeawoghewiaghewihgilewahgjiwaehgiewhga", count: 10)
	var bIsDeletingCell: Bool = false
	var deletingIndexPath: IndexPath? = nil
	var sourceViews: [[UIView]] = []
	var bombAnimationFlag: Int = 0
	var bombAnimationRow: Int = 0
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
}

extension MKDeleteCellTableViewController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath) as? DeleteCell else {
			return DeleteCell()
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? DeleteCell, self.bIsDeletingCell == false else {
			return
		}
		self.cellStartAnimation(with: cell)
		self.bIsDeletingCell = true
		self.deletingIndexPath = indexPath
		self.tableView.isScrollEnabled = false
	}
}

extension MKDeleteCellTableViewController {
	
	//Animation
	func cellStartAnimation(with cell: DeleteCell) {
		let srcImg = cell.containerView.screenshot()
		self.scaleAnimation(with: cell.contentView)
		sourceViews.removeAll()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
			self.sourceViews = self.cropItems(with: cell.containerView, srcImage: srcImg, to: cell.contentView)
			cell.containerView.alpha = 0
			self.bombAnimationFlag = 0
			self.bombAnimationRow = self.sourceViews.count - 1
			self.deleteViewAnimation()
		}
	}
	
	func scaleAnimation(with view: UIView) {
		let scaleAnimation = CAKeyframeAnimation.init(keyPath: "transform.scale")
		scaleAnimation.values = [1, 0.97, 1]
		scaleAnimation.keyTimes = [0, 0.5, 1]
		scaleAnimation.duration = 0.17
		scaleAnimation.repeatCount = 1
		scaleAnimation.isRemovedOnCompletion = true
		scaleAnimation.fillMode = .forwards
		view.layer.add(scaleAnimation, forKey: "scaleCellAnimation")
	}
	
	func cropItems(with srcView: UIView, srcImage: UIImage, to parentView: UIView) -> [[UIView]] {
		let newSize = CGSize.init(width: srcView.bounds.width / 24.0, height: srcView.bounds.height / 5.0)
		var datas: [[UIView]] = []
		for i in 0...23 {
			var itemViews: [UIView] = []
			for j in 0...4 {
				let scale = UIScreen.main.scale
				let subX = newSize.width * CGFloat(i) * scale
				let subY = newSize.height * CGFloat(j) * scale
				let subWidth = newSize.width * scale
				let subHeight = newSize.height * scale
				let subRect = CGRect.init(x: subX, y: subY, width: subWidth, height: subHeight)
				guard let subImageRef = srcImage.cgImage?.cropping(to: subRect) else {
					continue
				}
				let subImage = UIImage.init(cgImage: subImageRef)
				let subImageView = UIImageView.init(image: subImage)
				let subImageViewX = newSize.width * CGFloat(i)
				let subImageViewY = newSize.height * CGFloat(j)
				subImageView.frame = CGRect.init(x: subImageViewX, y: subImageViewY, width: newSize.width, height: newSize.height)
				parentView.addSubview(subImageView)
				itemViews.append(subImageView)
			}
			datas.append(itemViews)
		}
		return datas
	}
	
	@objc func deleteViewAnimation() {
		if self.bombAnimationRow < 0 {
			for itemViews: [UIView] in self.sourceViews {
				for itemView: UIView in itemViews {
					itemView.removeFromSuperview()
				}
			}
			if let deleteIndexPath = self.deletingIndexPath {
				DispatchQueue.main.async {
					self.dataSource.remove(at: deleteIndexPath.row)
					self.tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
				}
			}
			self.sourceViews.removeAll()
			self.bIsDeletingCell = false
			self.tableView.isScrollEnabled = true
			
			return
		}
		
		var itemViews: [UIView] = self.sourceViews[self.bombAnimationRow]
		let existOne: Int = Int.random(in: 0 ... 4)
		var existTwo: Int = Int.random(in: 0 ... 4)
		while existOne == existTwo {
			existTwo = Int.random(in: 0 ... 4)
		}
		var indexArray: [Int] = [0, 1, 2, 3, 4]
		if let index = indexArray.index(of: existOne) {
			indexArray.remove(at: index)
		}
		if let index = indexArray.index(of: existTwo) {
			indexArray.remove(at: index)
		}
		let oneView = itemViews[indexArray[0]]
		let twoView = itemViews[indexArray[1]]
		let threeView = itemViews[indexArray[2]]
		
		oneView.alpha = 0
		twoView.alpha = 0
		threeView.alpha = 0
		if let index = itemViews.index(of: oneView) {
			itemViews.remove(at: index)
		}
		
		if let index = itemViews.index(of: twoView) {
			itemViews.remove(at: index)
		}
		
		if let index = itemViews.index(of: threeView) {
			itemViews.remove(at: index)
		}
		
		if self.bombAnimationFlag == 1 {
			var itemViews = self.sourceViews[self.bombAnimationRow + 1]
			let dRandom = Int.random(in: 0 ... 2)
			if dRandom == 0 {
				let view = itemViews[0]
				view.alpha = 0
				itemViews.remove(at: 0)
			} else {
				let view = itemViews[1]
				view.alpha = 0
				itemViews.remove(at: 1)
			}
		}
		
		if self.bombAnimationFlag == 2 {
			let itemViews2 = self.sourceViews[self.bombAnimationRow + 2]
			for view in itemViews2 {
				view.alpha = 0
			}
			
			var itemViews1 = self.sourceViews[self.bombAnimationRow + 1]
			let dRandom = Int.random(in: 0 ... 2)
			if dRandom == 0 {
				let view = itemViews1[0]
				view.alpha = 0
				itemViews1.remove(at: 0)
			} else {
				let view = itemViews1[1]
				view.alpha = 0
				itemViews1.remove(at: 1)
			}
		}
		
		if self.bombAnimationRow + 2 <= self.sourceViews.count - 1 {
			let itemViews2 = self.sourceViews[self.bombAnimationRow + 2]
			for view in itemViews2 {
				view.alpha = 0
			}
		}
		
		self.bombAnimationFlag += 1
		if self.bombAnimationFlag == 3 {
			self.bombAnimationFlag = 0
		}
		self.bombAnimationRow -= 1
		self.perform(#selector(deleteViewAnimation), with: nil, afterDelay: 1 / 48)
	}
}

class DeleteCell: UITableViewCell {
	
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var contentLabel: UILabel!
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}
