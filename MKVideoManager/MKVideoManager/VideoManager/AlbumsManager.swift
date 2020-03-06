//
//  AlbumsManager.swift
//  MKVideoManager
//
//  Created by yahaw on 2020/3/3.
//  Copyright © 2020 xiaoxiang. All rights reserved.
//

import UIKit
import Photos

struct AlbumsFolderItem {
      var folderName: String?
      var items: [PHAsset] = []

      init(folderName: String?, items: [PHAsset]) {
          self.folderName = folderName
          self.items = items
      }
}

class AlbumsManager: NSObject {
	static let manager = AlbumsManager()
	var imageRequestingIds: [PHImageRequestID] = []

	override private init() {
		super.init()
	}

	class func checkPhotoLibraryPermission( completeBlock: @escaping((Bool) -> Void)) {
         let authStatus = PHPhotoLibrary.authorizationStatus()
         if authStatus == .notDetermined {
             PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
                 DispatchQueue.main.async {
                     if status == .authorized {
                         completeBlock(true)
                     } else {
                         completeBlock(false)
                     }
                 }
             }
         } else {
             let auth = (authStatus == .authorized)
             completeBlock(auth)
         }
     }
     //获取所有相册
	class func loadAlbumsComplete( completeBlock: (@escaping([AlbumsFolderItem]) -> Void)) {
         var albums: [AlbumsFolderItem] = []

         let options = PHFetchOptions()
          // 所有智能相册集合(系统自动创建的相册)
         let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
         for index in 0 ..< smartAlbums.count {
             //得到一个相册,一个集合就是一个相册
			let collection: PHCollection = smartAlbums[index]
			if collection is PHAssetCollection {
                let assetArr: [PHAsset] = self.getAllPHAssetFromOneAlbum(assetCollection: collection as! PHAssetCollection)
				if assetArr.count > 0 {
					let folder: AlbumsFolderItem = AlbumsFolderItem(folderName: collection.localizedTitle, items: assetArr)
					albums.append(folder)
                 }
             }
         }
		completeBlock(albums)
     }

     //获取一个相册里的所有图片的PHAsset对象
    class func getAllPHAssetFromOneAlbum( assetCollection: PHAssetCollection) -> ([PHAsset]) {
         // 存放所有图片对象
		var arr: [PHAsset] = []
         // 是否按创建时间排序b
		let options = PHFetchOptions()
		//时间排序
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		//只选照片
		options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
         // 获取所有图片资源对象
		let results: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)

		// 遍历，得到每一个图片资源asset，然后放到集合中
		results.enumerateObjects { (asset, _, _) in
			arr.append(asset)
		}
         return arr
     }
	/**
	asset: 图片对象
	targetSize: 目标尺寸 当传入size为0的时候，取原始图片大小
	isExclusive: 排他性 自动取消前面具有排他性的其他请求
	complete: 图片请求结束的回调
	*/
	class func loadImageWithAsset( asset: PHAsset, targetSize: CGSize = CGSize(width: 56, height: 56), isExclusive: Bool = false, complete: @escaping ((UIImage?) -> Void)) {
		let option = PHImageRequestOptions()
		option.isNetworkAccessAllowed = true //支持下载iCloud的图片
		var aimSize = targetSize
		if aimSize.equalTo(CGSize.zero) {
			aimSize = PHImageManagerMaximumSize
		}
		if isExclusive {
			AlbumsManager.manager.canclePreviousImageRequest()
		}

		let requestId = PHImageManager.default().requestImage(for: asset, targetSize: aimSize, contentMode: .aspectFill, options: option) { (image, _) in
			var resultImage: UIImage? = image
			if image != nil {
				resultImage = self.checkImageAndResetImageSuitable(image: image!)
			}

			if Thread.isMainThread {
				complete(resultImage)
			} else {
				DispatchQueue.main.async {
					complete(resultImage)
				}
			}
			if isExclusive {
				AlbumsManager.manager.imageRequestingIds.removeLast()
			}
		}
		if isExclusive {
			AlbumsManager.manager.imageRequestingIds.append(requestId)
		}
	}

	fileprivate class func checkImageAndResetImageSuitable(image: UIImage) -> (UIImage?) {
		let maxImageSize = CGSize(width: 500, height: 500)
		let maxImageFileSize = 3 * 1024 * 1024
		var resultImage = image
		resultImage = self.resetImageSizeSuitable(image: resultImage, maxSize: maxImageSize)
		resultImage = self.resetImageFileSizeSuitable(image: resultImage, maxSize: maxImageFileSize)
		return resultImage
	}

	fileprivate class func resetImageSizeSuitable(image: UIImage, maxSize: CGSize) -> (UIImage) {
		var resultImage = image
		guard resultImage.size.width > maxSize.width, resultImage.size.height > maxSize.height else {
			return resultImage
		}

		let rate = min(maxSize.width / resultImage.size.width, maxSize.height / resultImage.size.height)
		let aimSize = CGSize(width: resultImage.size.width * rate, height: resultImage.size.height * rate)
		UIGraphicsBeginImageContext(aimSize)
		resultImage.draw(in: CGRect(x: 0, y: 0, width: aimSize.width, height: aimSize.height))
		resultImage = UIGraphicsGetImageFromCurrentImageContext() ?? resultImage
		UIGraphicsEndImageContext()

		return resultImage
	}

	fileprivate class func resetImageFileSizeSuitable(image: UIImage, maxSize: Int) -> (UIImage) {
		let resultImage = image
		var jpegData = resultImage.jpegData(compressionQuality: 1.0)
		let imageDataSize = jpegData?.count ?? 0
		guard imageDataSize > maxSize else {
			return resultImage
		}

		var compression: CGFloat = 1
		var max: CGFloat = 1
		var min: CGFloat = 0
		for _ in 0 ..< 6 {
			compression = (max + min) / 2
			jpegData = resultImage.jpegData(compressionQuality: compression)
			guard jpegData != nil else {
				return resultImage
			}
			if CGFloat(jpegData!.count) < CGFloat(maxSize) * 0.9 {
				min = compression
			} else if jpegData!.count > maxSize {
				max = compression
			} else {
				break
			}
		}
		guard let imageRes = UIImage(data: jpegData!) else {
			return resultImage
		}
		return imageRes
	}
	 fileprivate func canclePreviousImageRequest() {
		guard self.imageRequestingIds.count > 0 else {
			return
		}
		for requestId in self.imageRequestingIds {
			PHImageManager.default().cancelImageRequest(requestId)
		}
		self.imageRequestingIds.removeAll()
	}
}
