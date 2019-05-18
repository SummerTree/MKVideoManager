//
//  MKVideoCommand.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import AVFoundation

typealias OperationFinishHandler = (_ url: URL?) -> Void

class MKVideoEditCommand: NSObject {
	
	func compositionVideoAndExport(with localUrl: URL, waterImage: UIImage? = nil, callback: @escaping OperationFinishHandler) {
		let (mixcomposition, videoComposition, audioMix) = MKVideoCompositionCommand.compostionVideo(videoUrl: localUrl, waterImage: waterImage)
		guard let mixCom = mixcomposition, let videoCom = videoComposition else {
			callback(nil)
			return
		}
		let exporter = MKVideoExportCommand()
		exporter.exportVideo(with: mixCom, videoComposition: videoCom, audioMixTools: audioMix, exportType: .writer, callback: callback)
	}
	
	func compositionVideoAndExport(with waterImage: UIImage?, firstUrl: URL, maskUrl: URL, preUrl: URL, maskScale: CGFloat, maskOffset: CGPoint, callback: @escaping OperationFinishHandler) {
		let (mixcomposition, videoComposition, audioMix) = MKVideoCompositionCommand.compositionStoryWithSys(waterImage, firstUrl, maskUrl, preUrl, maskScale: maskScale, maskOffset: maskOffset)
		guard let mixCom = mixcomposition, let videoCom = videoComposition else {
			callback(nil)
			return
		}
		let exporter = MKVideoExportCommand()
		exporter.exportVideo(with: mixCom, videoComposition: videoCom, audioMixTools: audioMix, exportType: .writer, callback: callback)
	}
	
	func compositionVideo(with firstUrl: URL, maskUrl: URL, maskScale: CGFloat, maskOffset: CGPoint, callback: @escaping OperationFinishHandler) {
		
		let (mixcomposition, videoComposition, audioMix) = MKVideoCompositionCommand.compositionVideo(with: firstUrl, maskUrl: maskUrl, maskScale: maskScale, maskOffset: maskOffset)
		guard let mixCom = mixcomposition, let videoCom = videoComposition else {
			callback(nil)
			return
		}
		let exporter = MKVideoExportCommand()
		exporter.exportVideo(with: mixCom, videoComposition: videoCom, audioMixTools: audioMix, exportType: .writer, callback: callback)
	}
	
	func compositionVideoToPlay(with waterImage: UIImage?, firstUrl: URL, maskUrl: URL, preUrl: URL, maskScale: CGFloat, maskOffset: CGPoint) -> AVComposition?{
		let (mixcomposition, videoComposition, _) = MKVideoCompositionCommand.compositionStoryWithSys(waterImage, firstUrl, maskUrl, preUrl, maskScale: maskScale, maskOffset: maskOffset)
		guard let mixCom = mixcomposition, let _ = videoComposition else {
			return nil
		}
		return mixCom
	}
}
