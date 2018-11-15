//
//  MKVideoCoverViewController.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/14.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

class MKVideoCoverViewController: UIViewController {
    
    var collectionView: UICollectionView?
    
    var coverArray: NSMutableArray?
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.setSubViews()
    }
    
    func setSubViews() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize.init(width: UIScreen.main.bounds.width / 9, height: 100)
        flowLayout.headerReferenceSize = CGSize(width: 10, height: 100)
        flowLayout.footerReferenceSize = CGSize(width: 10, height: 100)
        collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 88, width: UIScreen.main.bounds.width, height: 100), collectionViewLayout: flowLayout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "coverCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.allowsMultipleSelection = false
        self.view.addSubview(collectionView!)
        
    }
    
    func setCoverData() {
        coverArray = NSMutableArray.init(capacity: 9)
        
    }
}

extension MKVideoCoverViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
//        return self.coverArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coverCell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.orange
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
