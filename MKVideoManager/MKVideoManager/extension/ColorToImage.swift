//
//  ColorToImage.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/15.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

import UIKit

extension UIImage {
    static func getImageWithColor(_ color: UIColor) -> UIImage {
        return self.getImageWith(color, CGSize(width: 1, height: 1))
    }
    static func getImageWith(_ color: UIColor, _ size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    func imageMontage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)

        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
