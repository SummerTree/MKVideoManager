//
//  TextColorInputView.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/12.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit

protocol ColorsInputViewDelegate : NSObjectProtocol {
    func didSelectedColor(_ color:UIColor)
    func didSelectedIndex(_ index: Int)
}

class ColorsInputView: UIView {
    
    weak var delegate: ColorsInputViewDelegate? = nil
    var collectionView: UICollectionView!
    
    var colors: [UIColor]?
    var selectedColorIndex: Int? = 0 {
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    func initWithColors(_ colors: [UIColor]) {
        self.colors = colors
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        selectedColorIndex = 0
        self.setSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSubViews() {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        defaultLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        defaultLayout.itemSize = CGSize(width: 32, height: 32)
        defaultLayout.minimumLineSpacing = (UIScreen.main.bounds.width - 20 - 32*10) / 9.0
        defaultLayout.minimumInteritemSpacing = 0
        defaultLayout.headerReferenceSize = CGSize(width: 10, height: 44)
        defaultLayout.footerReferenceSize = CGSize(width: 0, height: 0)
        self.collectionView = UICollectionView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width , height:44), collectionViewLayout: defaultLayout)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.register(ColorCollectionCell.self, forCellWithReuseIdentifier: "colorCell")
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
}

extension ColorsInputView : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ColorCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionCell

        if self.selectedColorIndex == indexPath.row {
            cell.isSelected = true
        }else{
            cell.isSelected = false
        }
        
        cell.normalContentView?.backgroundColor = self.colors?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.color
         print("color--------------------------")
        guard self.selectedColorIndex != indexPath.row else {
            return
        }
        
        self.selectedColorIndex = indexPath.row
        let color = self.colors?[indexPath.row]
        print("color: \(String(describing: color))")
        if self.delegate != nil {
            self.delegate?.didSelectedColor(color ?? UIColor.white)
            self.delegate?.didSelectedIndex(self.selectedColorIndex!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }

}
