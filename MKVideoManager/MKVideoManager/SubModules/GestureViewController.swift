//
//  GestureViewController.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/13.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

class GestureViewController: UIViewController {
    var gesView: UITextView!
    override func viewDidLoad() {
//        self.navigationController?.isNavigationBarHidden = true
        self.setViews()
    }

	var fontSize: CGFloat = 15
    func setViews() {
//        gesView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 140))
		gesView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 140))
		gesView.text = "UITEXTVIEW"
		gesView.font = UIFont.systemFont(ofSize: fontSize)
		gesView.textColor = UIColor.black
		gesView.textAlignment = .center
		gesView.isEditable = false
        gesView.backgroundColor = UIColor.purple
        self.view.addSubview(gesView)

        gesView.center = self.view.center
        self.addGestureToView(gesView)
    }

    func addGestureToView(_ toView: UIView) {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        let pinchGes = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        let rotationGes = UIRotationGestureRecognizer(target: self, action: #selector(rotationAction(_:)))

        self.view.addGestureRecognizer(tapGes)
        self.view.addGestureRecognizer(panGes)
        self.view.addGestureRecognizer(pinchGes)
        self.view.addGestureRecognizer(rotationGes)
//        toView.addGestureRecognizer(tapGes)
//        toView.addGestureRecognizer(panGes)
//        toView.addGestureRecognizer(pinchGes)
//        toView.addGestureRecognizer(rotationGes)
    }

	@objc func tapAction(_ gesture: UITapGestureRecognizer) {
    }

	@objc func panAction(_ gesture: UIPanGestureRecognizer) {
        //设置矩形的位置
		let translation = gesture.translation(in: gesView.superview)
		let newP = CGPoint(x: gesView.center.x + translation.x, y: gesView.center.y + translation.y)
		gesView.center = newP
		gesture.setTranslation(CGPoint.zero, in: gesView.superview)
    }

	fileprivate var lastScale: CGFloat = 1.0
	@objc func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        print("gesture.scale: \(gesture.scale)")
		if(gesture.state == .ended) {
			gesView.font = UIFont.systemFont(ofSize: fontSize * gesture.scale)
			lastScale = 1.0
			return
		}

		let scale = 1.0 - (lastScale - gesture.scale)

		let newTransform = self.gesView.transform.scaledBy(x: scale, y: scale)

		self.gesView.transform = newTransform
		lastScale = gesture.scale
    }

	@objc func rotationAction(_ gesture: UIRotationGestureRecognizer) {
		gesView.transform = gesView.transform.rotated(by: gesture.rotation)
		gesture.rotation = 0
    }
}
