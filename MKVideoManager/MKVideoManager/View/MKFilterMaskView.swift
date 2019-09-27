//
//  MKFilterMaskView.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/14.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

protocol MKFilterMaskViewDelegate: NSObjectProtocol {
    func maskViewDidHide(_ outputModel: FilterModel)
}

class MKFilterMaskView: UIView {
    //view
    var headerView: UIView!
    var colorTypeButton: UIButton!
    var doneButton: UIButton!
    //textView
    var editControlView: UIView!
    var editTextView: EditTextView!
    //colorsView
    var colorsInputView: ColorsInputView!
    weak var delegate: TextEditMaskManagerDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setSubViews() {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    func setHeaderView() {
    }

    func setTextEditView() {
    }

    func setTextColorView() {
    }

    func setData(_ input: FilterModel) {
    }
}
