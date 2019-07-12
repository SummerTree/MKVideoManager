//
//  MKExportStoryConfiguration.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class MKExportStoryConfiguration: NSObject {
    //输出的视频尺寸
	static let outputVideoSize: CGSize = CGSize(width: 720, height: 1280)
    //输出的图片尺寸
	static let outputPhotoSize: CGSize = CGSize(width: 1080, height: 1920)
    //视频路径
	static let videoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyvideo")
    //图片路径
	static let photoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyphoto")
    //导出水印
	static let watermarkImage: UIImage? = UIImage(named: "watermark")
    //导出水印位置
	static let watermarkPosition: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
}
