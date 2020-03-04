//
//  PhotoZoomItem.swift
//  MKVideoManager
//
//  Created by yahaw on 2020/3/4.
//  Copyright © 2020 xiaoxiang. All rights reserved.
//

import UIKit
import Photos

class PhotoZoomItem: UIScrollView {
    var imageView: UIImageView!
    var asset:PHAsset! {
        willSet (newAsset) {
            PHImageManager.default().requestImage(for: newAsset, targetSize: self.frame.size, contentMode: .aspectFill, options: nil) { (image, _) in
                           self.imageView.image = image
            }
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initialAppearance() {
        self.delegate = self
//        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 2.0

        imageView = UIImageView.init(frame: self.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
        
    }
    
    func resetZoom()  {
        //还原
        self.zoomScale = 1.0
        self.imageView.frame = self.bounds
    }
}

extension PhotoZoomItem: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        // 延中心点缩放
//        CGFloat imageScaleWidth = scrollView.zoomScale * self.imageNormalWidth;
//        CGFloat imageScaleHeight = scrollView.zoomScale * self.imageNormalHeight;
//        CGFloat imageX = 0;
//        CGFloat imageY = 0;
//        if (imageScaleWidth < self.frame.size.width) {
//            imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
//        }
//        if (imageScaleHeight < self.frame.size.height) {
//            imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
//        }
//        self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    }
    
    
}
