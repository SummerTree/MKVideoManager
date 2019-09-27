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
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 6
        flowLayout.minimumInteritemSpacing = 6
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        flowLayout.itemSize = CGSize(width: 60, height: 60)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MKRefreshCollectionViewCell.self, forCellWithReuseIdentifier: "MKRefreshCollectionViewCell")
		collectionView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 100, right: 0)
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
    }

    func setRefresh() {
        self.collectionView.xr.addPullToRefreshHeader(refreshHeader: XRActivityRefreshHeader(), heightForHeader: 40, ignoreTopHeight: 60) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.xr.endHeaderRefreshing()
            })
        }
        self.collectionView.xr.addPullToRefreshFooter(refreshFooter: XRActivityRefreshFooter(), heightForFooter: 40, ignoreBottomHeight: 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.xr.endFooterRefreshing()
            })
        }
    }

    func setMJRefresh() {
        let headerView: MJRefreshNormalHeader = MJRefreshNormalHeader {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.mj_header.endRefreshing()
            })
        }

        let footerView: MJRefreshAutoNormalFooter = MJRefreshAutoNormalFooter {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.mj_footer.endRefreshing()
            })
        }

        self.collectionView.mj_header = headerView
        self.collectionView.mj_footer = footerView
    }

    func setCustomRefresh() {
        self.collectionView.addRefreshHeaderAction {[weak self] in
            guard let self = `self` else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.endHeaderRefresh()
            })

            //refresh new
        }

        self.collectionView.addRefreshFooterAction {[weak self] in
            guard let self = `self` else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.collectionView.endFooterRefresh()
            })

            //load more
        }
    }
}

extension MKRefreshControlViewController {
}

extension MKRefreshControlViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
