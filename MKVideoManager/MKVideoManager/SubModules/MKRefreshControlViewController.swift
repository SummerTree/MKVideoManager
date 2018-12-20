//
//  File.swift
//  MKVideoManager
//
//  Created by holla on 2018/12/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class MKRefreshControlViewController: UIViewController {
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setSubViews()
//        self.setRefresh()
//        self.setMJRefresh()
        self.setCustomRefresh()
    }
    
    func setSubViews() {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.minimumLineSpacing = 6
        flowLayout.minimumInteritemSpacing = 6
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 7, 0, 7)
        flowLayout.itemSize = CGSize.init(width: 60, height: 60)
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MKRefreshCollectionViewCell.self, forCellWithReuseIdentifier: "MKRefreshCollectionViewCell")
        collectionView.contentInset = UIEdgeInsetsMake(100, 0, 100, 0)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
    }
    
    func setRefresh() {
        self.collectionView.xr.addPullToRefreshHeader(refreshHeader: XRActivityRefreshHeader.init(), heightForHeader: 40, ignoreTopHeight: 60) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.xr.endHeaderRefreshing()
            })
        }
        self.collectionView.xr.addPullToRefreshFooter(refreshFooter: XRActivityRefreshFooter.init(), heightForFooter: 40, ignoreBottomHeight: 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.xr.endFooterRefreshing()
            })
        }
    }
    
    func setMJRefresh() {
        let headerView: MJRefreshNormalHeader = MJRefreshNormalHeader.init {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.mj_header.endRefreshing()
            })
        }

        let footerView: MJRefreshAutoNormalFooter = MJRefreshAutoNormalFooter.init {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.mj_footer.endRefreshing()
            })
        }

        self.collectionView.mj_header = headerView
        self.collectionView.mj_footer = footerView
        
        
    }
    
    func setCustomRefresh() {
        self.collectionView.addRefreshHeaderAction {[weak self] in
            guard let self = `self` else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.endHeaderRefresh()
            })
            
            //refresh new
        }
        
        self.collectionView.addRefreshFooterAction {[weak self] in
            guard let self = `self` else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.endFooterRefresh()
            })
            
            //load more
        }
    }
}

extension MKRefreshControlViewController{
    
}

extension MKRefreshControlViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MKRefreshCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MKRefreshCollectionViewCell", for: indexPath) as! MKRefreshCollectionViewCell
        cell.backgroundColor = UIColor.blue
        return cell
    }
}
