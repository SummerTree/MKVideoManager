//
//  PhotoViewerViewController.swift
//  MKVideoManager
//
//  Created by yahaw on 2020/3/2.
//  Copyright © 2020 xiaoxiang. All rights reserved.
//

import UIKit
import Photos

class PhotoViewerListCell: UITableViewCell {
    @IBOutlet weak var folderIconImageView: UIImageView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var folderCountLabel: UILabel!

	var album: AlbumsFolderItem! {
        willSet (newAlbum) {
            folderNameLabel.text = newAlbum.folderName
            folderCountLabel.text = "\(newAlbum.items.count)"
            guard let asset = newAlbum.items.last else {
                return
            }
			AlbumsManager.loadImageWithAsset(asset: asset) { (image: UIImage?) in
				guard image != nil else {
					return
				}
				self.folderIconImageView.image = image
			}
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        folderIconImageView.layer.cornerRadius = 6.0
        folderIconImageView.layer.masksToBounds = true
    }
}

class PhotoViewerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var albums: [AlbumsFolderItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
        self.fetchImagesFromAlbums()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    fileprivate func fetchImagesFromAlbums() {
        AlbumsManager.checkPhotoLibraryPermission {[weak self] (permission: Bool) in
			guard permission else { return }
			AlbumsManager.loadAlbumsComplete {[weak self] (albums: [AlbumsFolderItem]) in
				guard let self = `self` else { return }
				self.albums = albums
				self.tableView.reloadData()
			}
        }
    }

    func initAppearance() {
        let nib = UINib(nibName: "PhotoViewerListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PhotoViewerListCell")
        tableView.tableFooterView = UIView()
    }
}

extension PhotoViewerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PhotoViewerListCell = tableView.dequeueReusableCell(withIdentifier: "PhotoViewerListCell") as! PhotoViewerListCell
        cell.album = albums[indexPath.row]
       return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let imageArr: [PHAsset] = albums[indexPath.row].items
        let selectVC: PhotoSelectViewController = PhotoSelectViewController()
        selectVC.images = imageArr
        self.navigationController?.pushViewController(selectVC, animated: true)
    }
}
