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
	lazy var indicator: UIActivityIndicatorView = {
		let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
		return indicator
	}()
	
    var asset: PHAsset! {
        willSet (newAsset) {
			self.indicator.startAnimating()
			AlbumsManager.loadImageWithAsset(asset: newAsset, targetSize: CGSize.zero, isExclusive: true) { (image: UIImage?) in
				guard image != nil else {
					return
				}
				self.indicator.stopAnimating()
				self.imageView.image = image
				if image == nil {
					self.imageView.image = UIImage(named: "image_default")
				}
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
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 2.0

        imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
    }

	func resetZoom() {
        //还原
        self.zoomScale = 1.0
        self.imageView.frame = self.bounds
    }
}

extension PhotoZoomItem: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
	}

	func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
	}

	func scrollViewDidZoom(_ scrollView: UIScrollView) {
    }
}
