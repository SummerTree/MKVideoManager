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
    public static let outputVideoSize:CGSize = CGSize.init(width: 720, height: 1280)
    
    //输出的图片尺寸
    public static let outputPhotoSize:CGSize = CGSize.init(width: 1080, height: 1920)
    
    //视频路径
    public static let videoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyvideo")
    
    //图片路径
    public static let photoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyphoto")
    
    //导出水印
    public static let watermarkImage:UIImage? = UIImage.init(named: "watermark")
    //导出水印位置
    public static let watermarkPosition:UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 10)
}
