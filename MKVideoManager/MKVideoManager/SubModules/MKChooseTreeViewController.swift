//
//  MKChooseTreeViewController.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

import UIKit

class MKChooseTreeVIewController: UIViewController {
    var image: UIImage?
    var imageView: UIImageView?

    override func viewDidLoad() {
        imageView = UIImageView(frame: MKDefine.screenBounds)
        imageView!.backgroundColor = UIColor.white
        imageView?.image = self.image
        self.view.addSubview(imageView!)
    }
//
    func setContentImage(_ image: UIImage) {
        self.image = image
    }
}
