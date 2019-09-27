//
//  MKTextEdit.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/12.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

class MKViewToImageViewController: UIViewController {
    var textView: UITextView!
    var savePic: UIButton!
    var imageView: UIImageView!
    var image: UIImage?
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.setSubViews()
    }

    func setSubViews() {
        if (self.textView == nil) {
            self.textView = UITextView(frame: CGRect(x: 40, y: 200, width: UIScreen.main.bounds.width - 80, height: 60))
            self.textView.textColor = UIColor.white
            self.textView.font = UIFont.boldSystemFont(ofSize: 24)
            self.textView.textAlignment = NSTextAlignment.center
            self.textView.backgroundColor = UIColor.clear
            self.textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
            self.view.addSubview(self.textView)
        }

        if self.savePic == nil {
            self.savePic = UIButton(frame: CGRect(x: 40, y: self.textView.frame.maxY + 40, width: UIScreen.main.bounds.width - 80, height: 60))
            self.savePic.addTarget(self, action: #selector(saveClicked), for: .touchUpInside)
            self.savePic.setTitle("save", for: .normal)
            self.savePic.backgroundColor = UIColor.purple
            self.savePic.setTitleColor(UIColor.black, for: .normal)
//            self.savePic.setBackgroundImage(UIIma, for: <#T##UIControl.State#>)
            self.view.addSubview(self.savePic)
        }

        if self.imageView == nil {
            self.imageView = UIImageView(frame: CGRect(x: 40, y: self.savePic.frame.maxY + 40, width: UIScreen.main.bounds.width - 80, height: 200))
            self.imageView.backgroundColor = UIColor.clear
            self.view.addSubview(self.imageView)
        }
    }

    @objc func saveClicked() {
        self.textView.resignFirstResponder()
//        self.textView.attributedText
        let image = self.textView.asImage()
        self.imageView.image = image
        print("sssssave")
    }
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
}

extension MKViewToImageViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let textView = object as! UITextView
        var topOffset = textView.bounds.height - textView.contentSize.height * textView.zoomScale / 2.0
        if topOffset < 0 {
            topOffset = 0
        }
        textView.contentOffset = CGPoint(x: 0, y: -topOffset)
    }
}
