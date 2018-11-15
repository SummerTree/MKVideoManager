//
//  MKVideoEdit.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/12.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit
class MKVideoEditViewController: UIViewController {
    var textEditButton: UIButton!
    var maskViewManager: TextEditMaskManager!
    var deltaY: CGFloat = 0
    var maskViews: [UIView]?
    var textEditModel: FilterModel?
    var originCenter: CGPoint!
    var netRotation : CGFloat = 1;//旋转
    var lastScaleFactor : CGFloat! = 1  //放大、缩小
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.setSubViews()
        self.addKeyboardObserve()
    }
    
    func setSubViews() {
        if self.textEditButton == nil {
            self.textEditButton = UIButton.init(frame: CGRect.init(x: 40, y: 200, width: UIScreen.main.bounds.width - 80, height: 60))
            self.view.addSubview(self.textEditButton)
            self.textEditButton.setTitle("Aa", for: .normal)
            self.textEditButton.setTitleColor(UIColor.blue, for: .normal)
            self.textEditButton.addTarget(self, action: #selector(showMask), for: .touchUpInside)
        }
    }
    
    @objc func showMask() {
        if self.maskViewManager == nil {
            self.maskViewManager = TextEditMaskManager.shared
            self.maskViewManager.delegate = self
        }
        self.maskViewManager.showMaskViewWithView(nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.maskViewManager.delegate = nil
        self.maskViewManager = nil
    }
}

extension MKVideoEditViewController{
    
    func addKeyboardObserve(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(note: NSNotification) {
        let userInfo = note.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.deltaY = keyBoardBounds.size.height
        print("deltaY: \(self.deltaY)")
        
        let animations:(() -> Void) = {
            //键盘的偏移量
            self.maskViewManager.reloadEditViewControlHeight(self.deltaY)
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    func keyboardWillHidden(note: NSNotification) {
        let userInfo  = note.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            //键盘的偏移量
            
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
}

extension MKVideoEditViewController: TextEditMaskManagerDelegate{
    func maskManagerDidOutputView(_ outputView: UIView) {
        let view = outputView as! EditTextView
        view.isEditable = false
        view.isSelectable = false
        self.view.addSubview(view)
        self.addGestureToView(view)
        
        view.snp.makeConstraints { (make) in
            make.center.equalTo(view.filterModel!.center!)
            make.size.equalTo(view.filterModel!.size!)
        }
        view.layoutIfNeeded()
        if view.filterModel?.transform != nil {
            view.transform = (view.filterModel?.transform!)!
        }
//        view.transform = CGAffineTransform(rotationAngle: view.filterModel!.rotation)
//        view.transform = CGAffineTransform(scaleX: view.filterModel!.scale, y: view.filterModel!.scale)
    }
}

extension MKVideoEditViewController : UIGestureRecognizerDelegate{
    func addGestureToView(_ view: UIView) {
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tap(_:)))
        view.addGestureRecognizer(tapGes)
        let panGes = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(panGes)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchAction(_:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        let rotateGesture = UIRotationGestureRecognizer(target: self, action:#selector(rotationAction(_:)))
        rotateGesture.delegate = self
        view.addGestureRecognizer(rotateGesture)
    }
    
    //MARK: Gesture Action
    func tap(_ gesture: UITapGestureRecognizer) {
        
        let filterView = gesture.view as! EditTextView
        filterView.superview?.bringSubview(toFront: filterView)
        self.maskViewManager.showMaskViewWithView(filterView)
        filterView.removeFromSuperview()
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        let translation  = gesture.translation(in: self.view)
        //设置矩形的位置
        let filterView = gesture.view as! EditTextView
        filterView.superview?.bringSubview(toFront: filterView)
        if gesture.state == UIPanGestureRecognizer.State.began {
            originCenter = filterView.filterModel?.center
        }
        let center = CGPoint(x: originCenter.x + translation.x, y: originCenter.y + translation.y)
        
        if gesture.state == UIPanGestureRecognizer.State.ended {
            originCenter = center
            filterView.filterModel?.center = center
        }
        filterView.snp.updateConstraints { (make) in
            make.center.equalTo(center)
        }
    }
    
    func pinchAction(_ gesture: UIPinchGestureRecognizer) {
        print("gesture.scale: \(gesture.scale)")
        let factor = gesture.scale
        
        let filterView = gesture.view as! EditTextView
        
        if gesture.state == UIGestureRecognizer.State.began {
            lastScaleFactor = 1
        }
        print("lastScaleFactor: \(String(describing: lastScaleFactor))")
        let newScale = 1 + factor - lastScaleFactor
        print("newScale: \(newScale)")
//        filterView.transform = CGAffineTransform(scaleX: factor, y: factor)
       filterView.transform = filterView.transform.scaledBy(x: newScale , y: newScale)
        lastScaleFactor = factor
        //状态是否结束，如果结束保存数据
        if gesture.state == UIGestureRecognizer.State.ended{
//            lastScaleFactor = factor
            filterView.filterModel?.scale = lastScaleFactor
            filterView.filterModel?.transform = filterView.transform
        }
       
    }
    
    func rotationAction(_ gesture: UIRotationGestureRecognizer) {
        
        
        //浮点类型，得到sender的旋转度数
        print("rotation: \(gesture.rotation)")
        let rotation : CGFloat = gesture.rotation
        let filterView = gesture.view as! EditTextView
        
        if gesture.state == UIPanGestureRecognizer.State.began {
            netRotation = 0
        }
        print("netRotation: \(netRotation)")
        let newRotation = rotation - netRotation
        filterView.transform = filterView.transform.rotated(by: newRotation)
        print("newRotation: \(newRotation)")
        netRotation = rotation
        //状态结束，保存数据
        if gesture.state == UIGestureRecognizerState.ended{
            filterView.filterModel?.rotation = netRotation
            filterView.filterModel?.transform = filterView.transform
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
