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
    
    var gesView: UIView!
    override func viewDidLoad() {
//        self.navigationController?.isNavigationBarHidden = true
        self.setViews()
    }
    
    func setViews() {
        gesView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 140))
        gesView.backgroundColor = UIColor.purple
        self.view.addSubview(gesView)
    
        gesView.center = self.view.center
        self.addGestureToView(gesView)
    }
    
    func addGestureToView(_ toView: UIView) {
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_:)))
        let panGes = UIPanGestureRecognizer.init(target: self, action: #selector(panAction(_:)))
        let pinchGes = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchAction(_:)))
        let rotationGes = UIRotationGestureRecognizer.init(target: self, action: #selector(rotationAction(_:)))
        
        self.view.addGestureRecognizer(tapGes)
        self.view.addGestureRecognizer(panGes)
        self.view.addGestureRecognizer(pinchGes)
        self.view.addGestureRecognizer(rotationGes)
//        toView.addGestureRecognizer(tapGes)
//        toView.addGestureRecognizer(panGes)
//        toView.addGestureRecognizer(pinchGes)
//        toView.addGestureRecognizer(rotationGes)
    }
    
    func tapAction(_ gesture: UITapGestureRecognizer) {
        
    }
    
    func panAction(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self.view)
        
        //设置矩形的位置
        self.gesView?.center = point
    }
    
    func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        print("gesture.scale: \(gesture.scale)")
        let width = self.gesView.bounds.width
        let height = self.gesView.bounds.height
        self.gesView.bounds.size = CGSize(width: width * gesture.scale, height: height * gesture.scale)
        
    }
    
    func rotationAction(_ gesture: UIRotationGestureRecognizer) {
        self.gesView.transform = CGAffineTransform(rotationAngle: gesture.rotation*(180/(CGFloat(Double.pi))))
        
    }
}
