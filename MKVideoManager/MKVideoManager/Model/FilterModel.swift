//
//  TextMidel.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/14.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

import UIKit

class FilterModel: NSObject{
    var transform: CGAffineTransform?
    
    var rotation: CGFloat = 0
    
    var scale: CGFloat! = 1
    
    var rect: CGRect?
    
    var center: CGPoint?
    
    var size: CGSize?
    
    var userEnable: Bool?
    
    var text: String?
    
    var arrtibuteText: NSAttributedString?
    
    var textColor: UIColor? = UIColor.white
    
    var textColorSelectedIndex: Int?
    
    var image: UIImage?
    
//    var filterView: UIView?
}
