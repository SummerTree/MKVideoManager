//
//  PhotoSelectViewController.swift
//  MKVideoManager
//
//  Created by yahaw on 2020/3/3.
//  Copyright © 2020 xiaoxiang. All rights reserved.
//

import UIKit
import Photos

typealias SelectHandler = (PHAsset) -> ()

class PhotoSelectItemCell : UICollectionViewCell {
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var imageMaskView: UIView!
    @IBOutlet weak var selectStateLabel: UILabel!
    
    var selectBlock: SelectHandler?
    var currentIndex: Int! = 0 {
        willSet (newIndex) {
            guard currentIndex != newIndex else {
                return
            }
            if newIndex != 0 {
                selectStateLabel.text = "\(newIndex!)"
                selectStateLabel.layer.borderWidth = 0
                selectStateLabel.backgroundColor = UIColor.init(red: 100 / 255.0, green: 74 / 255.0, blue: 241 / 255.0, alpha: 1.0)
                imageMaskView.isHidden = false
            } else {
                selectStateLabel.text = "";
                selectStateLabel.layer.borderWidth = 1.0
                selectStateLabel.backgroundColor = UIColor.clear
                imageMaskView.isHidden = true

            }
        }
    }

    var asset: PHAsset! {
        willSet (newAsset) {
            PHImageManager.default().requestImage(for: newAsset, targetSize: CGSize(width: 56, height: 56), contentMode: .aspectFill, options: nil) { (image, _) in
                self.contentImageView.image = image
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.itialAppearance()
    }
    
    func itialAppearance() {
        selectStateLabel.layer.cornerRadius = 10.0
        selectStateLabel.layer.masksToBounds = true
        selectStateLabel.layer.borderWidth = 1.0
        selectStateLabel.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func slectAction(_ sender: UIControl) {
        guard selectBlock != nil else {
            return
        }
        selectBlock!(asset)
    }
}

class PhotoSelectViewController: UIViewController {

    @IBOutlet weak var previewBg: UIView!
    @IBOutlet weak var previewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    var images:[PHAsset]!
    var selectImages: [PHAsset] = []
    let previewHieght = ScreenWidth / 375.0 * 300
    lazy var photoZoom: PhotoZoomItem = {
        let photoZoom:PhotoZoomItem = PhotoZoomItem.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: ScreenWidth, height: previewHieght)))
        return photoZoom
    }()

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.register(UINib(nibName: "PhotoSelectItemCell", bundle: nil), forCellWithReuseIdentifier: "PhotoSelectItemCell")
        previewBg.addSubview(photoZoom)
    }
    func checkShowHederPreview() {
        let needShowPreview = selectImages.count > 0
        if needShowPreview , previewHeightCon.constant == 0  {
            previewHeightCon.constant = previewHieght;
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        } else if !needShowPreview ,previewHeightCon.constant > 0 {
            previewHeightCon.constant = 0;
            photoZoom.resetZoom()
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func updateSelectImage(asset:PHAsset) {
        if selectImages.contains(asset) {
            selectImages.remove(at: selectImages.firstIndex(of: asset)!)
        } else {
            selectImages.append(asset)
        }
        if selectImages.count > 0 {
            //更换图片
            updateCurrentPreImage(asset: selectImages.last!)
        }
        checkShowHederPreview()
    }
    
    func updateCurrentPreImage(asset:PHAsset) {
        photoZoom.asset = asset
    }
}

extension PhotoSelectViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = images[indexPath.row]
        let cell: PhotoSelectItemCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoSelectItemCell", for: indexPath) as! PhotoSelectItemCell
        cell.asset = asset
        cell.selectBlock = {[weak self] (asset: PHAsset) -> () in
            guard self != nil else {
                return
            }
            self!.updateSelectImage(asset: asset)
            self!.updatesVisibleCellSlectState()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (ScreenWidth - 6) / 4.0
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let asset = images[indexPath.row]
        var index = 0
        if selectImages.contains(asset) {
            index = selectImages.firstIndex(of: asset)! + 1
        }
        (cell as! PhotoSelectItemCell).currentIndex = index
    }
    
    func updatesVisibleCellSlectState() {
        let visibleCells = collectionView.visibleCells
        guard visibleCells.count > 0 else {
            return
        }
        for cell in visibleCells {
            let currentCell: PhotoSelectItemCell = cell as! PhotoSelectItemCell
            var index = 0
            if selectImages.contains(currentCell.asset) {
                index = selectImages.firstIndex(of: currentCell.asset)! + 1
            }
            currentCell.currentIndex = index
        }
    }
}
