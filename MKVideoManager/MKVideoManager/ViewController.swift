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
    let modules: [String] = ["文字编辑与UI生成图片","给视频打水印","UI交互操作","取视频封面","下拉刷新"]
    let controllers: [UIViewController.Type] = [MKViewToImageViewController.self, MKVideoEditViewController.self, GestureViewController.self, MKVideoCoverViewController.self, MKRefreshControlViewController.self]
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
        let vc = self.controllers[indexPath.row].init()
        vc.title = self.modules[indexPath.row]
//        let nav = UINavigationController.init(rootViewController: vc)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

