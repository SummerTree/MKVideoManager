//
//  AttributeStringExtention.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/13.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    static func getAttributeString(_ string: String, _ textColor:UIColor, _ backgroundColor: UIColor) -> NSMutableAttributedString {
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [
													NSAttributedString.Key.backgroundColor : backgroundColor,
													NSAttributedString.Key.foregroundColor : textColor,
													NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ])
        let attString = NSMutableAttributedString.init(attributedString: attributedString)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.center
		let dic = [NSAttributedString.Key.paragraphStyle: paraStyle]
        
        attString.addAttributes(dic, range: NSMakeRange(0, attString.length))
        return attString
    }
}
