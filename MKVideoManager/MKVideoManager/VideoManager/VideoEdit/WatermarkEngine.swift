//
//  WatermarkEngine.swift
//  MKVideoManager
//
//  Created by holla on 2019/7/10.
//  Copyright © 2019 xiaoxiang. All rights reserved.
//

import Foundation

class WatermarkEngine: NSObject {
//	static func animationForGif(with gifPath: NSString) -> CAKeyframeAnimation {
//		var animation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "content")
//		let gifData:Data = try! Data(contentsOf: URL(fileURLWithPath: gifPath as String))
//		let gifDataSource: CGImageSource =
//			CGImageSourceCreateWithData(gifData as CFData, nil)!
//		let gifImageCount: Int =
//			CGImageSourceGetCount(gifDataSource)
//
//		var images = [CGImage]()
//		var delays = [Int]()
//
//		for i in 0...gifImageCount-1 {
//			if let image = CGImageSourceCreateImageAtIndex(gifDataSource, i, nil) {
//				images.append(image)
//			}
//
//			let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i), source: gifDataSource)
//			delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
//		}
//		let duration: Int = {
//			var sum = 0
//
//			for val: Int in delays {
//				sum += val
//			}
//
//			return sum
//		}()
//
//		let gcd = gcdForArray(array: delays)
//		var frames = [UIImage]()
//
//		var frame: UIImage
//		var frameCount: Int
//		for i in 0..<gifImageCount {
//			frame = UIImage(cgImage: images[Int(i)])
//			frameCount = Int(delays[Int(i)] / gcd)
//
//			for _ in 0..<frameCount {
//				frames.append(frame)
//			}
//		}
//		animation.keyTimes =
//		animation.values = frames
//		animation.timingFunction =
//		animation.duration = duration
//		animation.repeatCount = HUGE_VALF
//
//		return animation
//	}

//	class func gcdForArray(array: Array<Int>) -> Int {
//		if array.isEmpty {
//			return 1
//		}
//
//		var gcd = array[0]
//
//		for val in array {
//			gcd = UIImage.gcdForPair(a: val, gcd)
//		}
//
//		return gcd
//	}
}
