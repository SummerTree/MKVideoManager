//
//  MKVideoCoverSlider.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/15.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

class MKVideoCoverSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
//        print("bounds: \(bounds)")
//        print("rect: \(rect)")
//        print("value: \(value)")
//        return rect
//    }
//    override func trackRect(forBounds bounds: CGRect) -> CGRect {
//        let rect = super.trackRect(forBounds: bounds)
//        
//        return CGRect.init(x: 0, y: 8, width: bounds.size.width, height: 64)
//    }

//    override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect.init(x: 0, y: 0, width: bounds.size.width - 60, height: bounds.size.height)
//    }
//
//    override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect.init(x: 400, y: 0, width: 100, height: 100)
//    }
}
