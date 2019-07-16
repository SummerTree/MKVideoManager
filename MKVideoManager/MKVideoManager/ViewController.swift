//
//  ViewController.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/12.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tableView: UITableView!
    let modules: [String] = ["文字编辑与UI生成图片", "给视频打水印", "UI交互操作", "取视频封面", "下拉刷新", "Sticker", "adjustTextFont", "滚动动画", "滚动动画2", "滚动动画3", "cell 删除动画", "视频合成、水印、导出、压缩", "Giphy UI", "Tenor gif", "PopTip", "numberLabel"]

    let controllers: [UIViewController.Type] = [MKViewToImageViewController.self, MKVideoEditViewController.self, GestureViewController.self, MKVideoCoverViewController.self, MKRefreshControlViewController.self, MKStickerViewController.self, MKAdjustFontViewController.self, MKScrollTableViewController.self, MKScrollTextViewController.self, MKScrollTextTimerViewController.self, MKDeleteCellTableViewController.self, MKVideoCompositionViewController.self, GiphyUIViewController.self, TenorViewController.self, PopTipViewController.self, ScrollNumberViewController.self]

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "MKVideoManager"
        self.setSubViews()
//        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setSubViews() {
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), style: UITableView.Style.grouped)
//        self.tableView.backgroundColor = UIColor.red
        self.tableView.dataSource = self
        self.tableView.delegate = self
       
        self.view.addSubview(self.tableView)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "cell")
        cell.textLabel?.text = self.modules[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  indexPath.row >= self.controllers.count {
            return
        }
		var vc: UIViewController
		if indexPath.row == 7 {
			vc = UIStoryboard.init(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "scrollTableVC") as! MKScrollTableViewController
		} else if indexPath.row == 8 {
			vc = UIStoryboard.init(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "scrollTextVC") as! MKScrollTextViewController
		} else if indexPath.row == 9 {
			vc = UIStoryboard.init(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "scrollTimerVC") as! MKScrollTextTimerViewController
		} else if indexPath.row == 10 {
			vc = UIStoryboard.init(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "deleteCellVC") as! MKDeleteCellTableViewController
		} else if indexPath.row == 11 {
			vc = UIStoryboard(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "compostionVC") as! MKVideoCompositionViewController
		} else if indexPath.row == 12 {
			vc = UIStoryboard.init(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "giphyVC") as! GiphyUIViewController
		} else if indexPath.row == 14 {
			vc = UIStoryboard(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "popTipVC") as! PopTipViewController
		} else if indexPath.row == 15 {
			vc = UIStoryboard(name: "MKStory", bundle: nil).instantiateViewController(withIdentifier: "numberLabelVC") as! ScrollNumberViewController
		} else {
			vc = self.controllers[indexPath.row].init()
		}
        vc.title = self.modules[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
