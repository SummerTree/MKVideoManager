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
	var test1Edit: VideoEditCommand?
	var test2Edit: VideoEditCommand?
	var test3Edit: VideoEditCommand?
	var test4Edit: VideoEditCommand?
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	deinit {
		print("dealloc")
	}
	
	@IBAction func compositionWithNoImage(_ sender: Any) {
		self.compositionWithNoImage()
	}
	@IBAction func compositionWithImage(_ sender: Any) {
		self.compositionWithImage(type: .MomentShareInstagram)
	}
	
	@IBAction func compositionAndExport(_ sender: Any) {
		self.compositionAndExport(type: .MomentShareSnapChat)
	}
	
	@IBAction func compositionToPlay(_ sender: Any) {
		let videoPath = Bundle.main.path(forResource: "main", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let maskPath = Bundle.main.path(forResource: "220", ofType: "mp4")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		let videoEdit = VideoEditCommand()
		videoEdit.compositionVideoAndExport(with: nil, firstUrl: videoUrl, maskUrl: maskUrl, maskScale: 0.25, maskOffset: CGPoint.init(x: 20, y: 90), callback: {[weak self] (exportUrl) in
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
			guard let url = exportUrl else {
				return
			}
			let asset = AVURLAsset.init(url: url)
			self.showPlayer(asset: asset)
		})
	}
	
	@IBAction func otherClicked(_ sender: Any) {
//		let waterImage = self.getWaterView().screenshot()
		
		let videoPath = Bundle.main.path(forResource: "main", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let maskPath = Bundle.main.path(forResource: "444", ofType: "mp4")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		let (mixcomposition, _, _) = VideoCompositionCommand.compositionStoryWithSys(videoUrl, maskUrl, maskScale: 0.25, maskOffset: CGPoint.init(x: 20, y: 90))
		guard let asset = mixcomposition else {
			return
		}
		//经过测试，mixcomposition 可以正常播放修改了音频的对象
		//如果修改了视频轨道，只能播放第一个添加的视频
		self.showPlayer(asset: asset)
	}
	
	@IBAction func compositionVideosClicked(_ sender: Any) {
		//同时合成多个视频并存储到本地
		self.compositionAndExport(type: .FamousShareSnapChat)
		self.compositionAndExport(type: .FamousShareInstagram)
		self.compositionAndExport(type: .FamousShareWhatsApp)
	}
	
	@IBAction func cancelClicked(_ sender: Any) {
		self.test1Edit?.cancel()
		self.test3Edit?.cancel()
		self.test2Edit?.cancel()
		self.test4Edit?.cancel()
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
			player.play()
		}
	}
	
	func compositionWithNoImage() {
		
		let videoPath = Bundle.main.path(forResource: "ariana", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let videoEdit = VideoEditCommand()
		videoEdit.compositionVideoAndExport(with: videoUrl, waterImage: nil ) {[weak self] (exportUrl) in
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
	func compositionWithImage(type: CompositionType) {
		let waterImage = self.getWaterView().screenshot()
		let videoPath = Bundle.main.path(forResource: "ariana", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let videoEdit = VideoEditCommand()
		videoEdit.compositionVideoAndExport(with: videoUrl, waterImage: waterImage, exportType: type.rawValue) {[weak self] (exportUrl) in
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
//			self.playVideo(with: exportUrl)
		}
	}
	
	
	
	func compositionAndExport(type: CompositionType) {
		let waterImage = self.getWaterView(type: type.rawValue).screenshot()
		
		let videoPath = Bundle.main.path(forResource: "ariana", ofType: "mp4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
		let maskPath = Bundle.main.path(forResource: "220", ofType: "mp4")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		let videoEdit = VideoEditCommand()
		TimeLog.logTime(logString: "start composition")
		videoEdit.compositionVideoAndExport(with: waterImage, firstUrl: videoUrl, maskUrl: maskUrl, maskScale: 0.25, maskOffset: CGPoint.init(x: 20, y: 90), exportType: type.rawValue, callback: {[weak self] (exportUrl) in
			TimeLog.logTime(logString: "finish composition")
			guard let `self` = self else {
				return
			}
			self.saveVideo(with: exportUrl)
//			self.playVideo(with: exportUrl)
		})
		
		switch type {
		case .MomentShareSnapChat:
			self.test1Edit = videoEdit
			break
		case .FamousShareSnapChat:
			self.test2Edit = videoEdit
			break
		case .FamousShareInstagram:
			self.test3Edit = videoEdit
			break
		case .FamousShareWhatsApp:
			self.test4Edit = videoEdit
			break
		default:
			break
		}
	}
	
	func playVideo(with url: URL?) {
		guard let url = url else {
			return
		}
		let asset = AVURLAsset.init(url: url)
		self.showPlayer(asset: asset)
	}
}

extension MKVideoCompositionViewController {
	func getWaterView(type: String? = nil) -> UIView {
		let scale = UIScreen.main.scale
		let bgView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth * scale, height: scale * ScreenWidth * 16 / 9))
		bgView.backgroundColor = UIColor.clear
		
		let waterView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 240 * scale, height: 16 * scale))
		waterView.backgroundColor = UIColor.init(red: 100.0/255.0, green: 74.0/255.0, blue: 241.0/255.0, alpha: 1)
		waterView.font = UIFont.systemFont(ofSize: 16 * scale, weight: .heavy)
		waterView.textColor = UIColor.white
		waterView.textAlignment = .center
		if let text = type {
			waterView.text = "\(text)".uppercased()
		}
		
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
		asset.loadValuesAsynchronously(forKeys: ["duration"]) {
			var error: NSError? = nil
			// Check for success of loading the assets tracks.
			let status: AVKeyValueStatus = asset.statusOfValue(forKey: "duration", error: &error)
			if status == .loaded {
				print(asset.duration)
			}

			if status == .failed {
				print("save to photoLibrary failed")
			}
		}
		
	}
}
