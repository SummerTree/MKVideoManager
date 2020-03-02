//
//  VideoWatermarkCommond.swift
//  Monkey
//
//  Created by holla on 2019/5/20.
//  Copyright © 2019 Monkey Squad. All rights reserved.
//

import Foundation
//import GiphyUISDK
class VideoWatermarkCommond: NSObject {
	/// 设置水印
	///
	/// - Parameters:
	///   - compostion: 合成器
	///   - waterImage: 水印
	///   - size: naturalSize视频大小
	static func applyViewEffectsToCompostion(_ compostion: AVMutableVideoComposition, _ waterImage: UIImage?, _ size: CGSize) {
		let overlayLayer = CALayer()
		overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		overlayLayer.masksToBounds = true

		let videoLayer = CALayer()

		videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		if let image = waterImage {
			let imgLayer = CALayer()
			imgLayer.contents = image.cgImage

			if size.width / size.height == 9.0 / 16.0 {
				//如果比例是6：19
				imgLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
			} else if size.width / size.height > 9.0 / 16.0 {
				//其他尺寸，如果比例大于6: 19，高度将被填充满，左右两边被裁剪
				imgLayer.bounds = CGRect(x: 0, y: 0, width: size.height * 9.0 / 16.0, height: size.height)
			} else if size.width / size.height < 9.0 / 16.0 {
				//如果比例小于6: 19,宽度被填充，上下两边被裁剪
				imgLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.width * 16.0 / 9.0)
			}

			imgLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
			overlayLayer.addSublayer(imgLayer)
			videoLayer.addSublayer(imgLayer)
		}
		let parentLayer = CALayer()
		parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		parentLayer.addSublayer(videoLayer)
		parentLayer.addSublayer(overlayLayer)

		compostion.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
	}

	static func applyFamousToCompostion(with compostion: AVMutableVideoComposition, commonWaterImage: UIImage?, size: CGSize) {
		let videoLayer = CALayer()
		videoLayer.masksToBounds = true
		videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		if let commonImage = commonWaterImage {
			let imgLayer = CALayer()
			imgLayer.contents = commonImage.cgImage
			imgLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)

			imgLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
			videoLayer.addSublayer(imgLayer)
		}

		let parentLayer = CALayer()
		parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		parentLayer.addSublayer(videoLayer)

		compostion.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
	}

//	static func applyViewEffectsToCompostion(_ compostion: AVMutableVideoComposition, _ gifImage: GPHMediaView?, _ size: CGSize) {
//		let overlayLayer = CALayer()
//		overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//		overlayLayer.masksToBounds = true
//
//		let videoLayer = CALayer()
//
//		videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//
////		if let image = waterImage {
////			let imgLayer = CALayer()
////			imgLayer.contents = image.cgImage
////
////			if size.width / size.height == 9.0 / 16.0 {
////				//如果比例是6：19
////				imgLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
////			} else if size.width / size.height > 9.0 / 16.0 {
////				//其他尺寸，如果比例大于6: 19，高度将被填充满，左右两边被裁剪
////				imgLayer.bounds = CGRect(x: 0, y: 0, width: size.height * 9.0 / 16.0, height: size.height)
////			} else if size.width / size.height < 9.0 / 16.0 {
////				//如果比例小于6: 19,宽度被填充，上下两边被裁剪
////				imgLayer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.width * 16.0 / 9.0)
////			}
////
////			imgLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
////			overlayLayer.addSublayer(imgLayer)
////			videoLayer.addSublayer(imgLayer)
////		}
//		let parentLayer = CALayer()
//		parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//
//		parentLayer.addSublayer(videoLayer)
//		parentLayer.addSublayer(overlayLayer)
//
//		compostion.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
//	}
}
