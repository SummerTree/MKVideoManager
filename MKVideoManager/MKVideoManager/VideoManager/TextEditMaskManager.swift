//
//  TextEditMaskManager.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/12.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


protocol TextEditMaskManagerDelegate: NSObjectProtocol {
    func maskViewDidHide()
    //
    func maskManagerDidOutputView(_ outputView: UIView)
}

class TextEditMaskManager: NSObject {
    
    static let navigationBarHeight:CGFloat = 44
    static let colorInputHeight:CGFloat = 44
    //maskView
    var maskView: UIView!
    //headerView
    var headerView: UIView!
    var colorTypeButton: UIButton!
    var doneButton: UIButton!
    //textView
    var editControlView: UIView!
    var editTextView: EditTextView!
    
    //colorsView
    var colorsInputView: ColorsInputView!
    
    var isNewFilter: Bool = false
//    var colorType: ColorType = .Text
	
    var keyBoardHeight:CGFloat?
    
    weak var delegate : TextEditMaskManagerDelegate?
    
    var filterModel: FilterModel!
    
    static let shared = TextEditMaskManager()
    override private init() {
        super.init()
        self.isNewFilter = true
        self.setFilterModel()
        self.setSubViews()
    }
    
    func setFilterModel() {
        //初始化时使用的model
        self.filterModel = FilterModel()
        self.filterModel.textColorSelectedIndex = 0
    }
    
    func showMaskViewWithView(_ inputView: UIView?) {
//		self.maskView.alpha = 0
//		self.getWindow().addSubview(self.maskView)
		//根据inputModel设置当前的编辑状态
		if let view = inputView as? MKCaptionLabel {
			//            let view = inputView as! EditTextView
//			let view = inputView as! MKCaptionLabel
			self.editTextView.attributedText = view.filterModel?.arrtibuteText
			self.filterModel = view.filterModel
			self.isNewFilter = false
			self.editTextView.tintColor = view.filterModel?.textColor
			self.editTextView.snp.updateConstraints { (make) in
				make.size.equalTo((view.filterModel?.size)!)
			}
		}else{
			self.editTextView.text = ""
			self.filterModel = FilterModel()
			self.isNewFilter = true
			self.editTextView.tintColor = UIColor.white
			self.editTextView.snp.updateConstraints { (make) in
				make.size.equalTo(CGSize.init(width: 44, height: 44))
			}
		}
		UIView.animate(withDuration: 0.25, animations: {
			self.maskView.alpha = 1
//			if
		}) { (complete) in
			self.reloadData(self.filterModel)
		}
    }
    
    @objc func hideMaskView() {
		
		
        //判断是否有文字
        if self.editTextView.text.count > 0 && self.delegate != nil{
            self.editControlView.layoutIfNeeded()
            let viewCenterY = self.editTextView.center.y + self.headerView.frame.maxY
            let viewCenter = CGPoint.init(x: UIScreen.main.bounds.width/2, y: viewCenterY)
            let viewSize = self.editTextView.bounds.size
            let copyView = self.editTextView.copyView() as! EditTextView
            let copyFilter = FilterModel()
            copyFilter.text = self.editTextView.text
            copyFilter.arrtibuteText = self.editTextView.attributedText
            copyFilter.size = viewSize
            copyFilter.textColor = self.filterModel.textColor
            
            if self.isNewFilter {
                copyFilter.center = viewCenter
                copyFilter.rect = self.editTextView.frame
            } else {
                copyFilter.center = self.filterModel.center!
                copyFilter.rotation = self.filterModel.rotation
                copyFilter.scale = self.filterModel.scale
                copyFilter.transform = self.filterModel.transform
                copyFilter.rect = self.filterModel.rect 
            }
            copyView.filterModel = copyFilter
            self.delegate?.maskManagerDidOutputView(copyView)
        }
		UIView.animate(withDuration: 0.25, animations: {
			self.maskView.alpha = 0
			if self.isNewFilter == false {
//				self.editTextView.center = self.filterModel.center!
//				self.editTextView.transform = self.filterModel.transform!
			}

		}) { (complete) in
			//			self.maskView.removeFromSuperview()
//			self.editTextView.center
		}
        self.delegate?.maskViewDidHide()
    }
    
    private func setSubViews() {
		
        //maskView
        self.maskView = UIView.init(frame: UIScreen.main.bounds)
		self.maskView.alpha = 0
        self.maskView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)

		
        //headerView
        self.headerView = UIView()
        self.maskView.addSubview(self.headerView)
        self.headerView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(MKDefine.statusBarHeight + 44)
        }
        
        self.colorTypeButton = UIButton()
        self.colorTypeButton.setTitle("Tt'", for: .normal)
        self.colorTypeButton.setTitleColor(UIColor.white, for: .normal)
        self.colorTypeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.headerView.addSubview(self.colorTypeButton)
        self.colorTypeButton.addTarget(self, action: #selector(colorTypeAction), for: .touchUpInside)
        self.colorTypeButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(MKDefine.statusBarHeight)
            make.size.equalTo(CGSize.init(width: 44, height: 40))
        }
        self.colorTypeButton.isHidden = true
        
        self.doneButton = UIButton()
        self.doneButton.setTitle("DONE", for: .normal)
        self.doneButton.setTitleColor(UIColor.white, for: .normal)
        self.doneButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        self.headerView.addSubview(self.doneButton)
        self.doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        self.doneButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(MKDefine.statusBarHeight)
            make.right.equalToSuperview().offset(-14)
            make.size.equalTo(CGSize.init(width: 60, height: 40))
        }
        
        //editTextView
        self.editControlView = UIView()
        self.maskView.addSubview(self.editControlView)
        let height = UIScreen.main.bounds.height - MKDefine.statusBarHeight - TextEditMaskManager.navigationBarHeight - 350 - TextEditMaskManager.colorInputHeight
        self.editControlView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
            make.height.equalTo(height)
        }
//        self.editControlView.backgroundColor = UIColor.purple
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideMaskView))
        self.editControlView.addGestureRecognizer(tap)
        
        self.editTextView = EditTextView()
//        self.editTextView.backgroundColor = UIColor.orange
        self.editTextView.delegate = self
        //textView关闭自动纠错提示
        self.editTextView.autocorrectionType = .no
        self.editTextView.textColor = UIColor.white
        self.editTextView.font = UIFont.boldSystemFont(ofSize: 24)
        self.editTextView.textAlignment = NSTextAlignment.center
        self.editTextView.backgroundColor = UIColor.clear
        self.editTextView.isScrollEnabled = false
        self.editControlView.addSubview(self.editTextView)
        self.editTextView.snp.makeConstraints { (make) in
            make.center.equalTo(self.editControlView)
            make.size.equalTo(CGSize.init(width: 44, height: 44))
        }
        
//        self.colorsInputView = ColorsInputView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
//        self.colorsInputView.delegate = self
//        self.maskView.addSubview(self.colorsInputView)
//        self.colorsInputView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(44)
//            make.bottom.equalToSuperview().offset(-346)
//        }
    }
    
    //MARK: - reload View
    func reloadData(_ input: FilterModel?) {
//        self.colorsInputView.selectedColorIndex = input?.textColorSelectedIndex
        self.editTextView.text = input?.text
    }
    
    func reloadEditViewControlHeight(_ keyBoardHeight: CGFloat) {
//        self.colorsInputView.snp.updateConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-keyBoardHeight)
//        }
        let height = UIScreen.main.bounds.height - MKDefine.statusBarHeight - TextEditMaskManager.navigationBarHeight - keyBoardHeight - TextEditMaskManager.colorInputHeight
        self.editControlView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
    
    //MARK: - Action
    @objc private func colorTypeAction(_ sender: UIButton){
//        if self.colorType == .Background {
//            self.colorType = .Text
//            sender.setTitle("Bg'", for: .normal)
//        }else{
//            self.colorType = .Background
//            sender.setTitle("Tt'", for: .normal)
//        }
    }
    
    @objc private func doneAction(_ sender: UIButton){
        self.hideMaskView()
    }
}

extension TextEditMaskManager: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView){
        if textView.text.count % 20  == 0{
            textView.text += "\n"
        }
        
        let currentString = NSMutableAttributedString.getAttributeString(textView.text, self.filterModel.textColor!, UIColor.clear)
        let size = currentString.boundingRect(with: CGSize.init(width: MKDefine.screenWidth - 40, height: 400), options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue), context: nil)
        print("size: \(String(describing: size))")
        textView.attributedText = currentString
        
        self.editTextView.snp.updateConstraints { (make) in
            make.size.equalTo(CGSize.init(width:20 + (size.width), height: 20 + (size.height)))
        }
    }
}

//extension TextEditMaskManager: ColorsInputViewDelegate {
//    enum ColorType {
//        case Text
//        case Background
//    }
//
//    func didSelectedColor(_ color: UIColor) {
//        switch self.colorType {
//        case .Text:
//            self.filterModel.textColor = color
//            self.editTextView.tintColor = color
//            self.editTextView.attributedText = NSMutableAttributedString.getAttributeString(self.editTextView.text, color, UIColor.clear)
//            break
//        case .Background:
//            self.editTextView.attributedText = NSMutableAttributedString.getAttributeString(self.editTextView.text, UIColor.white, color)
//            break
//        }
//    }
//
//    func didSelectedIndex(_ index: Int) {
//        self.filterModel.textColorSelectedIndex = index
//    }
//}

extension TextEditMaskManager{
    func getWindow()-> UIWindow {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.window!
    }
}
