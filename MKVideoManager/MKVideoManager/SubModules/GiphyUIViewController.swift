//
//  GiphyUIViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/8.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation
//import GiphyUISDK
//import GiphyCoreSDK
import Photos
import AVKit

class GiphyUIViewController: UIViewController {
//	@IBOutlet weak var imageView: GPHMediaView!

//	lazy var giphy: GiphyViewController = GiphyViewController()
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		GiphyUISDK.configure(apiKey: "A1iJrOA5GF44lsfV88lLcMSZ5l4OWXPB")
//		self.setupGiphyVC()
//	}
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(true )
//		present(self.giphy, animated: true, completion: nil)
//	}
//
//	fileprivate func setupGiphyVC() {
//		self.giphy.theme = .dark
//		self.giphy.layout = .waterfall
//		self.giphy.mediaTypeConfig = [.gifs, .stickers, .text, .emoji]
//		self.giphy.showConfirmationScreen = true
//		self.giphy.rating = .ratedPG13
//		self.giphy.renditionType = .fixedWidth
//		self.giphy.shouldLocalizeSearch = false
//		self.giphy.delegate = self
//	}
//	@IBAction func startClicked(_ sender: Any) {
//	}
//
//	func compositionWithImage(type: CompositionType) {
//		let waterImage = self.getWaterView().screenshot()
//		let videoPath = Bundle.main.path(forResource: "ariana", ofType: "mp4")
//		let videoUrl = URL(fileURLWithPath: videoPath!)
//
//		let videoEdit = VideoEditCommand()
//		videoEdit.compositionVideoAndExport(with: videoUrl, waterImage: waterImage, compositionType: type) {[weak self] (exportUrl) in
//			guard let `self` = self else {
//				return
//			}
//			self.saveVideo(with: exportUrl)
//			//			self.playVideo(with: exportUrl)
//		}
//	}
}

//extension GiphyUIViewController: GiphyDelegate {
//	func didSelectMedia(_ media: GPHMedia) {
//		// your user tapped a GIF!
////		self.imageView.media = media
//		let imageView = GPHMediaView()
//		imageView.media = media
//		imageView.backgroundColor = UIColor.red
////		let aspectRatio = medaiView.media?.aspectRatio
//		imageView.frame = CGRect(x: 10, y: 64, width: 300, height: 100)
//		self.view.addSubview(imageView)
//	}
//	func didDismiss(controller: GiphyViewController?) {
//		// your user dismissed the controller without selecting a GIF.
//	}
//}

//extension GiphyUIViewController {
//	func getWaterView(type: String? = nil) -> UIView {
//		let scale = UIScreen.main.scale
//		let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth * scale, height: scale * ScreenWidth * 16 / 9))
//		bgView.backgroundColor = UIColor.clear
//
//		let waterView = UILabel(frame: CGRect(x: 0, y: 0, width: 240 * scale, height: 16 * scale))
//		waterView.backgroundColor = UIColor(red: 100.0 / 255.0, green: 74.0 / 255.0, blue: 241.0 / 255.0, alpha: 1)
//		waterView.font = UIFont.systemFont(ofSize: 16 * scale, weight: .heavy)
//		waterView.textColor = UIColor.white
//		waterView.textAlignment = .center
//		if let text = type {
//			waterView.text = "\(text)".uppercased()
//		}
//
//		waterView.center = CGPoint(x: bgView.bounds.width / 2, y: bgView.bounds.height - 65 * scale)
//		bgView.addSubview(waterView)
//		return bgView
//	}
//
//	func saveVideo(with localUrl: URL?) {
//		guard let url = localUrl else {
//			print("export failed")
//			return
//		}
//		print(url.path)
//		let asset = AVURLAsset(url: url)
//		if asset.isCompatibleWithSavedPhotosAlbum {
//			PHPhotoLibrary.shared().performChanges({
//				PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//			}) { _, _ in
//				print("save to photoLibrary")
//			}
//		} else {
//			print("save to photoLibrary failed")
//		}
//		//		print(asset.duration)
//		asset.loadValuesAsynchronously(forKeys: ["duration"]) {
//			var error: NSError?
//			// Check for success of loading the assets tracks.
//			let status: AVKeyValueStatus = asset.statusOfValue(forKey: "duration", error: &error)
//			if status == .loaded {
//				print(asset.duration)
//			}
//
//			if status == .failed {
//				print("save to photoLibrary failed")
//			}
//		}
//	}
//}
