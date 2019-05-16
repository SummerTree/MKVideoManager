//
//  MKVideoCompostionViewController.swift
//  MKVideoManager
//
//  Created by holla on 2019/5/14.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation
import Photos

let ScreenHeight: CGFloat = UIScreen.main.bounds.height
let ScreenWidth: CGFloat = UIScreen.main.bounds.width

class MKVideoCompositionViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func compositionAction() {
		let waterImage = self.getWaterView().screenshot()
		let videoPath = Bundle.main.path(forResource: "000", ofType: "MP4")
		let videoUrl = URL(fileURLWithPath: videoPath!)
		
//		let maskPath = Bundle.main.path(forResource: "330", ofType: "MOV")
//		let maskUrl = URL(fileURLWithPath: maskPath!)
		let maskPath = Bundle.main.path(forResource: "002", ofType: "MOV")
		let maskUrl = URL(fileURLWithPath: maskPath!)
		MKAddWatermarkCommand.compositionStoryWithSys(waterImage, videoUrl, maskUrl) { (exportUrl) in
			
			guard let url = exportUrl else {
				print("export failed")
				return
			}
			print(url.path)
			PHPhotoLibrary.shared().performChanges({
				PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
			}) { saved, error in
				print("save to photoLibrary")
			}
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
		waterView.text = "swipe up to view profile".uppercased()
		waterView.center = CGPoint.init(x: bgView.bounds.width / 2, y: bgView.bounds.height - 65 * scale)
		bgView.addSubview(waterView)
		return bgView
	}

}
