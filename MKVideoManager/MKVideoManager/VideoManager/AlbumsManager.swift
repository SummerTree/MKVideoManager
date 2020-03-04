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
      var folderName: String?;
      var items:[PHAsset] = []
      init(folderName: String?, items:[PHAsset]) {
          self.folderName = folderName;
          self.items = items;
      }
}

class AlbumsManager: NSObject {
     
     static let manager = AlbumsManager()
     override private init() {}

     class func checkPhotoLibraryPermission( completeBlock: @escaping((Bool)->())){
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
   class func loadAlbumsComplete( completeBlock: (@escaping(Array<AlbumsFolderItem>) -> ())) {
         var albums:[AlbumsFolderItem] = []

         let options = PHFetchOptions.init()
                 // 所有智能相册集合(系统自动创建的相册)
         let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
         
         for index in 0 ..< smartAlbums.count {
             //得到一个相册,一个集合就是一个相册
             let collection:PHCollection  = smartAlbums[index];
             
             if collection is PHAssetCollection {
                let assetArr:[PHAsset] = self.getAllPHAssetFromOneAlbum(assetCollection: collection as! PHAssetCollection)
                 if assetArr.count > 0 {
                     let folder:AlbumsFolderItem = AlbumsFolderItem.init(folderName: collection.localizedTitle, items: assetArr)
                     albums.append(folder)
                 }
             }
         }
         completeBlock(albums)
     }
     
     //获取一个相册里的所有图片的PHAsset对象
    class func getAllPHAssetFromOneAlbum(assetCollection:PHAssetCollection)->([PHAsset]){
         // 存放所有图片对象
         var arr:[PHAsset] = []
         // 是否按创建时间排序
         let options = PHFetchOptions.init()
         options.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                     ascending: false)]//时间排序
         options.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)//˙只选照片
         // 获取所有图片资源对象
         let results:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
         
         // 遍历，得到每一个图片资源asset，然后放到集合中
         results.enumerateObjects { (asset, index, stop) in
             arr.append(asset)
         }
         
         return arr
     }
}
