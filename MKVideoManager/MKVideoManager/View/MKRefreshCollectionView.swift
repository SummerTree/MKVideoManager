//
//  MKRefreshCollectionView.swift
//  MKVideoManager
//
//  Created by holla on 2018/12/20.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import MJRefresh

class MKRefreshCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UICollectionView{
    
    func addRefreshHeaderAction(headerAction:@escaping (() -> Void )) {
        let headerView: MKRefreshHeaderView = MKRefreshHeaderView.init {
            headerAction()
        }
        self.mj_header = headerView
    }
    
    func addRefreshFooterAction(footerAction:@escaping (() -> Void )) {
        let footerView: MKRefreshFooterView = MKRefreshFooterView.init {
            footerAction()
        }
        self.mj_footer = footerView
    }
    
    func beginHeaderRefresh() {
        self.mj_header.beginRefreshing()
    }
    
    func endHeaderRefresh() {
        self.mj_header.endRefreshing()
    }
    
    func beginFooterRefresh() {
        self.mj_footer.beginRefreshing()
    }
    
    func endFooterRefresh() {
        self.mj_footer.endRefreshing()
    }
    
    func endFooterRefreshNoMoreData() {
        self.mj_footer.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        self.mj_footer.resetNoMoreData()
    }
}
