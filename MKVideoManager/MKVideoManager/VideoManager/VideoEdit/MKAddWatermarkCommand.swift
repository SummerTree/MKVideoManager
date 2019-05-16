//
//  MKAddWatermarkCommand.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation

import AVFoundation

class MKAddWatermarkCommand: MKVideoCommand {
	static private var exportVideoSize: CGSize = CGSize.init(width: 720, height: 1280)
	
	static private var exportUrl: URL = {
		return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("export_temp.mp4")
	}()
	
	static private func compostion(with mainAsset: AVURLAsset, otherAsset: AVURLAsset, callback:@escaping ((URL?) -> Void)) {
		
	}
	
	
	static private func setupAsset(asset: AVURLAsset) {
//		let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
//		let startTime = CMTimeMakeWithSeconds(0, preferredTimescale: asset.duration.timescale)
//		let seconds = Float(asset.duration.value) / Float(asset.duration.timescale)
//		let endTime = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: asset.duration.timescale)
//		let naturalSize = assetVideoTrack.naturalSize
	}
	
	static private func setupVideoTrack(asset: AVAsset, videoTrack: AVMutableCompositionTrack, startTime: CMTime) {
		//3 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
		let videoAssetTracks = asset.tracks(withMediaType: AVMediaType.video)
		if videoAssetTracks.isEmpty == true {
			//no video track error
			return
		}
		for videoAssetTrack: AVAssetTrack in videoAssetTracks {
			do{
				//把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
				try videoTrack.insertTimeRange(videoAssetTrack.timeRange, of: videoAssetTrack, at: startTime)
			}catch{
				print(error)
				return
			}
		}
	}
	
	static private func setupAudioTrack(asset: AVURLAsset, composition: AVMutableComposition, startTime: CMTime) -> AVMutableCompositionTrack? {
		guard let audioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)  else {
			return nil
		}
		
		//音频采集通道
		let audioAssetTracks = asset.tracks(withMediaType: AVMediaType.audio)
		
		if audioAssetTracks.isEmpty == true {
			//无音频轨道
			return nil
		}
		for audioAssetTrack: AVAssetTrack in audioAssetTracks {
			do {
				//音频通道
				try audioTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: startTime)
			} catch {
				print(error)
				return nil
			}
		}
		return audioTrack
	}
	
	static private func setupVideoProperties(with videoTrack: AVAssetTrack, startTime: CMTime, endTime: CMTime) -> AVVideoCompositionLayerInstruction? {
		let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
		return videoLayerInstruction
	}
	
	static private func transformTranslate(from videoTrack: AVAssetTrack) -> (CGAffineTransform, CGRect) {
		//判断方向这里有问题
		let orientation: UIInterfaceOrientation = self.videoCropOrientation(from: videoTrack)
		let portrait = (orientation == .portrait || orientation == .portraitUpsideDown)
		
		let naturalSize = videoTrack.naturalSize
		var newSize = naturalSize
		if portrait {
			newSize = CGSize.init(width: naturalSize.height, height: naturalSize.width)
		}
		
		var cropRect = self.cropVideoRect(from: newSize)
		let cropSize = cropRect.size
		
		// rotate and position video
		if portrait {
			cropRect.size = CGSize.init(width: cropSize.height, height: cropSize.width)
		}
		
		var cropOrigin = cropRect.origin
		if orientation == .landscapeLeft {
			// invert translation //iPhoneX录屏会导致视频下移
			cropOrigin.x *= -1
			cropOrigin.y *= -1
		} else if orientation == .portrait {
			cropOrigin.x *= -1
			cropOrigin.y *= -1
		}
		
		// t1: rotate and position video since it may have been cropped to screen ratio
		//preferredTransform not always CGAffineTransformIdentity
		let preTransform = videoTrack.preferredTransform
		//因为preferredTransform的各种属性并不一定准确，如：tx、ty， 如：a、b、c、d 不是 1，而是其他浮点数
		//这里重新设置视频的transform
		var trans = CGAffineTransform.identity
		
		if orientation == .portrait {
			if preTransform.tx == 0 {
				trans = CGAffineTransform.init(a: preTransform.a, b: preTransform.b, c: preTransform.c, d: preTransform.d, tx: naturalSize.height, ty: preTransform.ty)
			} else {
				trans = CGAffineTransform.init(a: preTransform.a, b: preTransform.b, c: preTransform.c, d: preTransform.d, tx: preTransform.tx, ty: preTransform.ty)
			}
		}
		
		if orientation == .portraitUpsideDown {
			if preTransform.ty == 0 {
				trans = CGAffineTransform.init(a: preTransform.a, b: preTransform.b, c: preTransform.c, d: preTransform.d, tx: preTransform.tx, ty: naturalSize.width)
			} else {
				trans = CGAffineTransform.init(a: preTransform.a, b: preTransform.b, c: preTransform.c, d: preTransform.d, tx: preTransform.tx, ty: preTransform.ty)
			}
		}
		
		if orientation == .landscapeRight {
			if preTransform.tx == 0 || preTransform.ty == 0 {
				trans = CGAffineTransform.init(a: preTransform.a, b: preTransform.b, c: preTransform.c, d: preTransform.d, tx: naturalSize.width, ty: naturalSize.height)
			} else {
				trans = CGAffineTransform.init(a: preTransform.a, b: preTransform.b, c: preTransform.c, d: preTransform.d, tx: preTransform.tx, ty: preTransform.ty)
			}
		}
		
		let t1 = trans.translatedBy(x: cropOrigin.x, y: cropOrigin.y)
		return (t1, cropRect)
	}
	
	static private func videoOrientation(from videoTrack: AVAssetTrack) -> UIInterfaceOrientation {
		//		let naturalSize = videoTrack.naturalSize
		let videoTransform = videoTrack.preferredTransform
		
		if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
			return .portrait
		}
		if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
			return .portraitUpsideDown
		}
		if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
			return .landscapeLeft
		}
		if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
			return .landscapeRight
		}
		
		return .landscapeLeft
	}
	
	static private func cropVideoRect(from videoSize: CGSize) -> CGRect {
		let expectRadio: CGFloat = 9.0 / 16.0
		let naturalRadio: CGFloat = videoSize.width / videoSize.height
		
		var cropRect = CGRect.zero
		if naturalRadio == expectRadio {
			// 如果比例是9：16
			cropRect.size = videoSize
		}else if naturalRadio > expectRadio {
			// 其他尺寸，如果比例大于9: 16，高度将被填充满，左右两边被裁剪
			let expectWidth = videoSize.height * expectRadio
			let cropX = (videoSize.width - expectWidth) / 2
			cropRect = CGRect.init(x: cropX, y: 0, width: expectWidth, height: videoSize.height)
		}else if naturalRadio < expectRadio {
			// 如果比例小于9: 16,宽度被填充，上下两边被裁剪
			let expectHeight = videoSize.width / expectRadio
			let cropY = (videoSize.height - expectHeight) / 2
			cropRect = CGRect.init(x: 0, y: cropY, width: videoSize.width, height: expectHeight)
		}
		
		var cropSize = cropRect.size
		
		var offsetW = Int(cropSize.width)%16
		var offsetH = Int(cropSize.height)%16
		
		offsetW = (offsetW == 0) ? 0 : 16 - offsetW
		offsetH = (offsetH == 0) ? 0 : 16 - offsetH
		
		cropSize = CGSize.init(width: cropSize.width + CGFloat(offsetW), height: cropSize.height + CGFloat(offsetH))
		cropRect.size = cropSize
		
		return cropRect
	}
	
	static private func transformRotation(from videoTrack: AVAssetTrack) -> (CGAffineTransform, CGSize) {
		// 视频方向修改
		let naturalSize = videoTrack.naturalSize
		var newNaturalSize = naturalSize
		//获取视频方向并修改transform
		let degree = self.degreeFromVideoFileWithURL(videoTrack)
		if degree != 0{
			var translateToCenter: CGAffineTransform = CGAffineTransform()
			var mixedTransform: CGAffineTransform = CGAffineTransform()
			if degree == 90.0 {
				translateToCenter = CGAffineTransform.init(translationX: naturalSize.height, y: 0.0)
				mixedTransform = translateToCenter.rotated(by: self.degreesToRadians(degree))
				newNaturalSize = CGSize.init(width: naturalSize.height, height: naturalSize.width)
			}else if degree == 180.0 {
				translateToCenter = CGAffineTransform.init(translationX: naturalSize.width, y: naturalSize.height)
				mixedTransform = translateToCenter.rotated(by: self.degreesToRadians(degree))
				newNaturalSize = CGSize.init(width: naturalSize.width, height: naturalSize.height)
			}else if degree == 270.0 {
				translateToCenter = CGAffineTransform.init(translationX: 0.0, y: naturalSize.width)
				mixedTransform = translateToCenter.rotated(by: self.degreesToRadians(degree))
				newNaturalSize = CGSize.init(width: naturalSize.height, height: naturalSize.width)
			}
			
			return (mixedTransform, newNaturalSize)
		}
		
		return (videoTrack.preferredTransform, newNaturalSize)
	}
	
	static private func videoCropOrientation(from videoTrack: AVAssetTrack) -> UIInterfaceOrientation {
		//		let naturalSize = videoTrack.naturalSize
		let videoTransform = videoTrack.preferredTransform
		
		if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
			return .portrait
		}
		if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
			return .portraitUpsideDown
		}
		if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
			return .landscapeLeft
		}
		if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
			return .landscapeRight
		}
		
		return .landscapeLeft
	}
	
	static func compositionStoryWithSys(_ watermarkImage: UIImage, _ videoUrl: URL, _ maskVideoUrl: URL, _ preVideoUrl: URL, callback:@escaping ((URL?) -> Void)){
		// 1 AVURLAsset 初始化视频媒体文件
		let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber.init(value: false)]
		let preAsset: AVURLAsset = AVURLAsset.init(url: preVideoUrl, options: opts)
		let asset: AVURLAsset = AVURLAsset.init(url: videoUrl, options: opts)
		let maskAsset: AVURLAsset = AVURLAsset.init(url: maskVideoUrl, options: opts)
		// 2 AVMutableComposition 创建AVMutableComposition实例.
		let mixComposition = AVMutableComposition()
		
		//3 AVMutableCompositionTrack 获取视频通道实例
		// --------------------track 0 pre track----------------------
		guard let preTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 1) else {
			callback(nil)
			return
		}
		self.setupVideoTrack(asset: preAsset, videoTrack: preTrack, startTime: CMTime.zero)
		
		// 3 设置合成的视频源
		// 3.1 AVMutableVideoCompositionLayerInstruction 对视频图层的操作，可以设置视频在指定时间的方向、位置、透明度、裁剪大小等
		let preLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: preTrack)
		//		let newSize = videoTrack.naturalSize
		//对视频轨道进行处理，调整视频，设置transform 和 opacity
		let (preTransform, preSize) = self.transformRotation(from: preTrack)
		preLayerInstruction.setTransform(preTransform, at: CMTime.zero)
		
		let preDuration: CMTime = preTrack.timeRange.duration
		preLayerInstruction.setOpacity(0, at: preDuration)
		// --------------------track 1----------------------
		guard let videoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 2) else {
			callback(nil)
			return
		}
		self.setupVideoTrack(asset: asset, videoTrack: videoTrack, startTime: preDuration)
		// 3 设置合成的视频源
		// 3.1 AVMutableVideoCompositionLayerInstruction 对视频图层的操作，可以设置视频在指定时间的方向、位置、透明度、裁剪大小等
		let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
//		let newSize = videoTrack.naturalSize
		//对视频轨道进行处理，调整视频，设置transform 和 opacity
		let (videoTransform, newSize) = self.transformRotation(from: videoTrack)
		videoLayerInstruction.setTransform(videoTransform, at: CMTime.zero)
		
		//opacity 默认为 1
		//		videoLayerInstruction.setOpacity(1, at: CMTime.zero)
		
		// --------------------track 2----------------------
		//3 AVMutableCompositionTrack 获取视频通道实例
		guard let maskTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: 3) else {
			callback(nil)
			return
		}
		self.setupVideoTrack(asset: maskAsset, videoTrack: maskTrack, startTime: preDuration)
		// 3 设置合成的视频源
		// 3.1 AVMutableVideoCompositionLayerInstruction 对视频图层的操作，可以设置视频在指定时间的方向、位置、透明度、裁剪大小等
		let maskVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: maskTrack)
		//对视频轨道进行处理，调整视频，设置transform 和 opacity
		let (maskVideoTransform, maskSize) = self.transformRotation(from: maskTrack)
		var newTransForm = maskVideoTransform.translatedBy(x: 20 * UIScreen.main.scale, y: 90 * UIScreen.main.scale)
		newTransForm = newTransForm.scaledBy(x: 0.25, y: 0.25)
		maskVideoLayerInstruction.setTransform(newTransForm, at: CMTime.zero)
		print("preSize: \(preSize)")
		print("firstSize: \(newSize)")
		print("secondSize: \(maskSize)")
		// 3.2 - Add instructions
		// AVMutableVideoCompositionInstruction 视频操作指令，设置合成视频的时长，背景颜色，合成视频的z轴层次等
		let mainInstruction = AVMutableVideoCompositionInstruction()
		
		//这里设置导出视频的时长
		let totoaRange: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeAdd(preTrack.timeRange.duration, videoTrack.timeRange.duration))
		mainInstruction.timeRange = totoaRange
		mainInstruction.backgroundColor = UIColor.red.cgColor
		//videoCompositionToolWithPostProcessingAsVideoLayer 时需要为 true， default = true
		//mainInstruction.enablePostProcessing = true
	
		//为视频分层，对于添加在相同时间的视频layer，先添加的在最顶层，后添加的在下层
		mainInstruction.layerInstructions = [preLayerInstruction, maskVideoLayerInstruction, videoLayerInstruction]
		
		// 4 AVMutableAudioMix 音频混合器，通过AVMutableAudioMixInputParameters 设置音频轨道
		let audioMixTools: AVMutableAudioMix = AVMutableAudioMix()
		var audioParameters: [AVMutableAudioMixInputParameters] = []
		var preAudioDuration: CMTime = CMTime.zero
		if let preAudioTrack: AVMutableCompositionTrack = self.setupAudioTrack(asset: preAsset, composition: mixComposition, startTime: CMTime.zero) {
			let mixInputParameter: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters.init(track: preAudioTrack)
			mixInputParameter.setVolumeRamp(fromStartVolume: 1, toEndVolume: 1, timeRange: preAudioTrack.timeRange)
			mixInputParameter.trackID = preAudioTrack.trackID
			audioParameters.append(mixInputParameter)
			preAudioDuration = preAudioTrack.timeRange.duration
			
		}
		
		if let maskAudioTrack: AVMutableCompositionTrack = self.setupAudioTrack(asset: maskAsset, composition: mixComposition, startTime: preAudioDuration) {
			let mixInputParameter: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters.init(track: maskAudioTrack)

			mixInputParameter.setVolumeRamp(fromStartVolume: 1, toEndVolume: 1, timeRange: maskAudioTrack.timeRange)

			mixInputParameter.trackID = maskAudioTrack.trackID
			audioParameters.append(mixInputParameter)
			
		}
		
		if let audioTrack: AVMutableCompositionTrack = self.setupAudioTrack(asset: asset, composition: mixComposition, startTime: preAudioDuration) {
			let mixInputParameter: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters.init(track: audioTrack)

			mixInputParameter.setVolumeRamp(fromStartVolume: 1, toEndVolume: 1, timeRange: audioTrack.timeRange)

			mixInputParameter.trackID = audioTrack.trackID
			audioParameters.append(mixInputParameter)
			
		}
		
		audioMixTools.inputParameters = audioParameters
		// 5 AVMutableVideoComposition：合成器 管理所有视频轨道，可以决定最终视频的尺寸
		let videoComposition = AVMutableVideoComposition()
		
		videoComposition.renderSize = preSize
		//		mainCompositionInst.renderScale = 1
		
		//合成需要执行的操作
		videoComposition.instructions = [mainInstruction]
		
		//frameDuration：视频帧的间隔 通常设置为30
		videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
		
		// 6 添加水印
		self.applyViewoEffectsToCompostion(videoComposition, watermarkImage, newSize)
		
		// 7 AVAssetExportSession 视频导出，可以设置导出视质量、导出位置、导出类型、视频合成器、音频混合器
		self.deleteExistingFile(url: self.exportUrl)
		let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
		exporter?.outputURL = self.exportUrl
		exporter?.outputFileType = AVFileType.mp4
		exporter?.shouldOptimizeForNetworkUse = true
		exporter?.videoComposition = videoComposition
		exporter?.audioMix = audioMixTools
		exporter?.exportAsynchronously(completionHandler: {
			if exporter?.status == AVAssetExportSession.Status.completed {
				guard let err = exporter?.error else{
					callback(self.exportUrl)
					return
				}
				print("err: \(err)")
				callback(nil)
			} else {
				print(exporter?.status ?? "----")
			}
		})
	}
	
	
	
	/// 获取视频s方向
	///
	/// - Parameter videoTrack: video track
	/// - Returns: degree
	static private func degreeFromVideoFileWithURL(_ videoTrack: AVAssetTrack) -> CGFloat {
		var degress: CGFloat = 0.0
		let t:CGAffineTransform = videoTrack.preferredTransform
		if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
			// Portrait
			degress = 90.0;
		}else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
			// PortraitUpsideDown
			degress = 270.0;
		}else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
			// LandscapeRight
			degress = 0.0;
		}else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
			// LandscapeLeft
			degress = 180.0;
		}
		return degress
	}
	
	/// 设置水印
	///
	/// - Parameters:
	///   - compostion: 合成器
	///   - waterImage: 水印
	///   - size: naturalSize视频大小
	static private func applyViewoEffectsToCompostion(_ compostion: AVMutableVideoComposition,_ waterImage: UIImage,_ size: CGSize){
		let imgLayer = CALayer.init()
		imgLayer.contents = waterImage.cgImage
		
		if size.width / size.height == 9.0 / 16.0 {
			//如果比例是6：19
			imgLayer.bounds = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		}else if size.width / size.height > 9.0 / 16.0 {
			//其他尺寸，如果比例大于6: 19，高度将被填充满，左右两边被裁剪
			imgLayer.bounds = CGRect.init(x: 0, y: 0, width: size.height * 9.0 / 16.0, height: size.height)
		}else if size.width / size.height < 9.0 / 16.0 {
			//如果比例小于6: 19,宽度被填充，上下两边被裁剪
			imgLayer.bounds = CGRect.init(x: 0, y: 0, width: size.width, height: size.width * 16.0 / 9.0)
		}
		
		imgLayer.position = CGPoint.init(x: size.width/2, y: size.height/2)
		
		let overlayLayer = CALayer.init()
		overlayLayer.addSublayer(imgLayer)
		overlayLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		overlayLayer.masksToBounds = true
		
		let parentLayer = CALayer.init()
		
		parentLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		
		let videoLayer = CALayer.init()
		videoLayer.addSublayer(imgLayer)
		videoLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
		
		parentLayer.addSublayer(videoLayer)
		parentLayer.addSublayer(overlayLayer)
		
		compostion.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
	}
	
	/// 通过degree获取应该旋转的角度
	///
	/// - Parameter degrees: degree
	/// - Returns: Radians
	static private func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
		return CGFloat.pi * degrees / 180
	}
	
	static private func deleteExistingFile(url: URL) {
		let fileManager = FileManager.default
		do {
			try fileManager.removeItem(at: url)
		}
		catch _ as NSError {
			print(#function)
		}
	}
}
