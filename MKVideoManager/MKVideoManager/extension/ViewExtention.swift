//
//  ViewExtention.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/16.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    private struct AssociatedKeys {
        static var filterModelKey = "filterModelKey"
    }
    var filterModel: FilterModel? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.filterModelKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.filterModelKey) as? FilterModel
        }
    }
    
}
