//
//  MKVideoCompostionViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/5/14.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation
import Photos
import AVKit

let ScreenHeight: CGFloat = UIScreen.main.bounds.height
let ScreenWidth: CGFloat = UIScreen.main.bounds.width

class MKVideoCompositionViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	deinit {
		print("dealloc")
	}
	
	@IBAction func compositionWithNoImage(_ sender: Any) {
	
		let videoPath = Bundle.main.path(forResource: "999", ofType: "MP4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let videoEdit = MKVideoEditCommand()
		videoEdit.compositionVideoAndExport(with: videoUrl, waterImage: nil) {[weak self] (exportUrl) in
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
			guard let url = exportUrl else {
				return
			}
			let asset = AVURLAsset.init(url: url)
			self.showPlayer(asset: asset)
		}
	}
	@IBAction func compositionWithImage(_ sender: Any) {
		let waterImage = self.getWaterView().screenshot()
		let videoPath = Bundle.main.path(forResource: "999", ofType: "MP4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let videoEdit = MKVideoEditCommand()
		videoEdit.compositionVideoAndExport(with: videoUrl, waterImage: waterImage) {[weak self] (exportUrl) in
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
			guard let url = exportUrl else {
				return
			}
			let asset = AVURLAsset.init(url: url)
			self.showPlayer(asset: asset)
		}
	}
	
	@IBAction func compositionAndExport(_ sender: Any) {
		let waterImage = self.getWaterView().screenshot()
		let prePath = Bundle.main.path(forResource: "pre", ofType: "mp4")
		let preUrl = URL(fileURLWithPath: prePath!)
		
		let videoPath = Bundle.main.path(forResource: "main", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let maskPath = Bundle.main.path(forResource: "999", ofType: "MP4")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		let videoEdit = MKVideoEditCommand()
		videoEdit.compositionVideoAndExport(with: waterImage, firstUrl: videoUrl, maskUrl: maskUrl, preUrl: preUrl, maskScale: 0.25, maskOffset: CGPoint.init(x: 20, y: 90)) {[weak self] (exportUrl) in
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
			guard let url = exportUrl else {
				return
			}
			let asset = AVURLAsset.init(url: url)
			self.showPlayer(asset: asset)
		}
	}
	@IBAction func compositionToPlay(_ sender: Any) {
		let videoPath = Bundle.main.path(forResource: "main", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let maskPath = Bundle.main.path(forResource: "pre", ofType: "mp4")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		let videoEdit = MKVideoEditCommand()
		videoEdit.compositionVideo(with: videoUrl, maskUrl: maskUrl, maskScale: 0.25, maskOffset: CGPoint.init(x: 20, y: 90)) {[weak self] (exportUrl) in
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
			guard let url = exportUrl else {
				return
			}
			let asset = AVURLAsset.init(url: url)
			self.showPlayer(asset: asset)
		}
	}
	
	@IBAction func otherClicked(_ sender: Any) {
		let waterImage = self.getWaterView().screenshot()
		let prePath = Bundle.main.path(forResource: "pre", ofType: "mp4")
		let preUrl = URL(fileURLWithPath: prePath!)
		
		let videoPath = Bundle.main.path(forResource: "main", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let maskPath = Bundle.main.path(forResource: "999", ofType: "MP4")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		let videoEdit = MKVideoEditCommand()
		guard let asset = videoEdit.compositionVideoToPlay(with: waterImage, firstUrl: videoUrl, maskUrl: maskUrl, preUrl: preUrl, maskScale: 0.25, maskOffset: CGPoint.init(x: 20, y: 90)) else {
			return
		}
		
		self.showPlayer(asset: asset)
	}
	func showPlayer(asset: AVAsset) {
		print(asset.duration)
		if asset.isPlayable == false {
			print("can't play")
			return
		}

		let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["tracks"])
		let player = AVPlayer.init(playerItem: playerItem)
		let playerVC = AVPlayerViewController()
		playerVC.player = player
		self.present(playerVC, animated: true) {
			
		}
	}
	
}

extension MKVideoCompositionViewController {
	func getWaterView() -> UIView {
		let scale = UIScreen.main.scale
		let bgView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth * scale, height: scale * ScreenWidth * 16 / 9))
		bgView.backgroundColor = UIColor.clear
		
		let waterView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 240 * scale, height: 16 * scale))
		waterView.backgroundColor = UIColor.init(red: 100.0/255.0, green: 74.0/255.0, blue: 241.0/255.0, alpha: 1)
		waterView.font = UIFont.systemFont(ofSize: 16 * scale, weight: .heavy)
		waterView.textColor = UIColor.white
		waterView.textAlignment = .center
		waterView.text = "CREATE YOUR OWN".uppercased()
		waterView.center = CGPoint.init(x: bgView.bounds.width / 2, y: bgView.bounds.height - 65 * scale)
		bgView.addSubview(waterView)
		return bgView
	}

	func saveVideo(with localUrl: URL?) {
		guard let url = localUrl else {
			print("export failed")
			return
		}
		print(url.path)
		let asset = AVURLAsset.init(url: url)
		if asset.isCompatibleWithSavedPhotosAlbum {
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
			}) { saved, error in
				print("save to photoLibrary")
			}
		} else {
			print("save to photoLibrary failed")
		}
//		print(asset.duration)
//		asset.loadValuesAsynchronously(forKeys: ["duration"]) {
//			var error: NSError? = nil
//			// Check for success of loading the assets tracks.
//			let status: AVKeyValueStatus = asset.statusOfValue(forKey: "duration", error: &error)
//			if status == .loaded {
//				print(asset.duration)
//
//			}
//
//			if status == .failed {
//				print("save to photoLibrary failed")
//			}
//		}
		
	}
}
