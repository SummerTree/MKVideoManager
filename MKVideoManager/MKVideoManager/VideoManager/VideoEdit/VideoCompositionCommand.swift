//
//  VideoEditCommond.swift
//  Monkey
//
//  Created by holla on 2019/5/18.
//  Copyright © 2019 Monkey Squad. All rights reserved.
//

import Foundation

import AVFoundation

class VideoCompositionCommand: NSObject {
	/// 对一个视频进行合成
	///
	/// - Parameters:
	///   - videoUrl: 本地视频路径
	///   - waterImage: 水印图片 （现在水印图片需要和视频大小相同，真正的水印放在透明的背景图上）
	/// - Returns: 导出视频需要的素材
	// swiftlint:disable:next large_tuple
	static func compostionVideo(videoUrl: URL, waterImage: UIImage?) -> (AVComposition?, AVMutableVideoComposition?, AVAudioMix?) {
		let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: false)]
		let asset: AVURLAsset = AVURLAsset(url: videoUrl, options: opts)

		let mixComposition = AVMutableComposition()
		guard let videoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
			return (nil, nil, nil)
		}
		self.setupVideoTrack(asset: asset, videoTrack: videoTrack, startTime: CMTime.zero)
		// AVMutableVideoCompositionLayerInstruction 对视频图层的操作，可以设置视频在指定时间的方向、位置、透明度、裁剪大小等
		let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

		//对视频轨道进行处理，调整视频，设置transform 和 opacity
		let (videoTransform, newSize) = self.transformRotation(from: videoTrack)
		videoLayerInstruction.setTransform(videoTransform, at: CMTime.zero)

		//opacity 默认为 1
		//		videoLayerInstruction.setOpacity(1, at: CMTime.zero)
		if asset.tracks(withMediaType: AVMediaType.audio).isEmpty == false, let audioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
			self.setupAudioTrack(asset: asset, audioTrack: audioTrack, startTime: CMTime.zero)
		}

		let mainInstruction = AVMutableVideoCompositionInstruction()

		//这里设置导出视频的时长
		let totoaRange: CMTimeRange = videoTrack.timeRange
		mainInstruction.timeRange = totoaRange
		mainInstruction.backgroundColor = UIColor.red.cgColor
		//videoCompositionToolWithPostProcessingAsVideoLayer 时需要为 true， default = true
		//mainInstruction.enablePostProcessing = true
		mainInstruction.layerInstructions = [videoLayerInstruction]

		let videoComposition = AVMutableVideoComposition()

		videoComposition.renderSize = newSize
		//		mainCompositionInst.renderScale = 1

		//合成需要执行的操作
		videoComposition.instructions = [mainInstruction]

		//frameDuration：视频帧的间隔 通常设置为30
		videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

		return (mixComposition, videoComposition, nil)
	}

	/// 对Monkey Famous视频进行合成
	///
	/// - Parameters:
	///   - videoUrl: 下载的明星视频本地地址
	///   - maskVideoUrl: 录制下来存在本地的视频地址
	///   - maskScale: maskVideo 缩放比例
	///   - maskOffset: maskVideo 从左上角偏移的位置，x: 向右偏移， y:向下偏移（对于设备屏幕）
	/// - Returns: 导出视频需要的素材
	// swiftlint:disable:next large_tuple
	static func compositionStoryWithSys(_ videoUrl: URL, _ maskVideoUrl: URL, maskScale: CGFloat, maskOffset: CGPoint) -> (AVComposition?, AVMutableVideoComposition?, AVAudioMix?) {
		// 1 AVURLAsset 初始化视频媒体文件
		let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: false)]
		let asset: AVURLAsset = AVURLAsset(url: videoUrl, options: opts)
		let maskAsset: AVURLAsset = AVURLAsset(url: maskVideoUrl, options: opts)
		// 2 AVMutableComposition 创建AVMutableComposition实例.
		let mixComposition = AVMutableComposition()

		//3 AVMutableCompositionTrack 获取视频通道实例
		// --------------------track 1----------------------
		guard let videoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
			return (nil, nil, nil)
		}
		// --------------------track 2----------------------
		//3 AVMutableCompositionTrack 获取视频通道实例
		guard let maskTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
			return (nil, nil, nil)
		}
		self.setupVideoTrack(asset: maskAsset, videoTrack: maskTrack, startTime: CMTime.zero)

		self.setupVideoTrack(asset: asset, videoTrack: videoTrack, startTime: CMTime.zero, suggestTimeRange: maskTrack.timeRange)
		// 3 设置合成的视频源
		// 3.1 AVMutableVideoCompositionLayerInstruction 对视频图层的操作，可以设置视频在指定时间的方向、位置、透明度、裁剪大小等
		let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
		//		let newSize = videoTrack.naturalSize
		//对视频轨道进行处理，调整视频，设置transform 和 opacity
		let (videoTransform, newSize) = self.transformRotation(from: videoTrack)
		videoLayerInstruction.setTransform(videoTransform, at: CMTime.zero)

		// 3 设置合成的视频源
		// 3.1 AVMutableVideoCompositionLayerInstruction 对视频图层的操作，可以设置视频在指定时间的方向、位置、透明度、裁剪大小等
		let maskVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: maskTrack)
		//对视频轨道进行处理，调整视频，设置transform 和 opacity
		let (maskVideoTransform, maskSize) = self.transformRotation(from: maskTrack)
		let offsetX: CGFloat = maskOffset.x * newSize.width / UIScreen.main.bounds.width
		let offsetY: CGFloat = maskOffset.y * newSize.height / UIScreen.main.bounds.height
		var newTransForm = maskVideoTransform.translatedBy(x: offsetX, y: offsetY)
		newTransForm = newTransForm.scaledBy(x: maskScale, y: maskScale)
		maskVideoLayerInstruction.setTransform(newTransForm, at: CMTime.zero)
		print("firstSize: \(newSize)")
		print("secondSize: \(maskSize)")
		// 3.2 - Add instructions
		// AVMutableVideoCompositionInstruction 视频操作指令，设置合成视频的时长，背景颜色，合成视频的z轴层次等
		let mainInstruction = AVMutableVideoCompositionInstruction()

		//这里设置导出视频的时长
		let totoaRange: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: maskTrack.timeRange.duration)
		mainInstruction.timeRange = totoaRange
		mainInstruction.backgroundColor = UIColor.red.cgColor
		//videoCompositionToolWithPostProcessingAsVideoLayer 时需要为 true， default = true
		//mainInstruction.enablePostProcessing = true

		//为视频分层，对于添加在相同时间的视频layer，先添加的在最顶层，后添加的在下层
		mainInstruction.layerInstructions = [maskVideoLayerInstruction, videoLayerInstruction]

		// 4 AVMutableAudioMix 音频混合器，通过AVMutableAudioMixInputParameters 设置音频轨道
		let audioMixTools: AVMutableAudioMix = AVMutableAudioMix()
		var audioParameters: [AVMutableAudioMixInputParameters] = []

		if asset.tracks(withMediaType: AVMediaType.audio).isEmpty == false, let audioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
			self.setupAudioTrack(asset: asset, audioTrack: audioTrack, startTime: CMTime.zero, suggestTimeRange: maskTrack.timeRange)
			let mixInputParameter: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioTrack)

			mixInputParameter.setVolumeRamp(fromStartVolume: 1, toEndVolume: 1, timeRange: audioTrack.timeRange)

			mixInputParameter.trackID = audioTrack.trackID
			audioParameters.append(mixInputParameter)
		}

		if maskAsset.tracks(withMediaType: AVMediaType.audio).isEmpty == false, let maskAudioTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
			self.setupAudioTrack(asset: maskAsset, audioTrack: maskAudioTrack, startTime: CMTime.zero)
			let mixInputParameter: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: maskAudioTrack)

			mixInputParameter.setVolumeRamp(fromStartVolume: 1, toEndVolume: 1, timeRange: maskAudioTrack.timeRange)

			mixInputParameter.trackID = maskAudioTrack.trackID
			audioParameters.append(mixInputParameter)
		}

		audioMixTools.inputParameters = audioParameters
		// 5 AVMutableVideoComposition：合成器 管理所有视频轨道，可以决定最终视频的尺寸
		let videoComposition = AVMutableVideoComposition()

		videoComposition.renderSize = newSize
		//		mainCompositionInst.renderScale = 1

		//合成需要执行的操作
		videoComposition.instructions = [mainInstruction]

		//frameDuration：视频帧的间隔 通常设置为30
		videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

		return (mixComposition, videoComposition, audioMixTools)
	}
}

extension VideoCompositionCommand {
	fileprivate static func setupVideoTrack(asset: AVAsset, videoTrack: AVMutableCompositionTrack, startTime: CMTime, suggestTimeRange: CMTimeRange? = nil) {
		//3 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
		let videoAssetTracks = asset.tracks(withMediaType: AVMediaType.video)
		if videoAssetTracks.isEmpty == true {
			//no video track error
			return
		}
		for videoAssetTrack: AVAssetTrack in videoAssetTracks {
			do {
				//把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
				//如果有suggestTimeRange 需要判断videoAssetTrack.timeRange 是否在suggestTimeRange中
				//如果超出了，需要剪切
				if let suggest = suggestTimeRange, videoAssetTrack.timeRange.containsTimeRange(suggest) {
					try videoTrack.insertTimeRange(suggest, of: videoAssetTrack, at: startTime)
				} else {
					try videoTrack.insertTimeRange(videoAssetTrack.timeRange, of: videoAssetTrack, at: startTime)
				}
			} catch {
				print(error)
				return
			}
		}
	}

	fileprivate static func setupAudioTrack(asset: AVAsset, audioTrack: AVMutableCompositionTrack, startTime: CMTime, suggestTimeRange: CMTimeRange? = nil) {
		//音频采集通道
		let audioAssetTracks = asset.tracks(withMediaType: AVMediaType.audio)
		let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
		let videoAssetTrack = asset.tracks(withMediaType: AVMediaType.video).first

		if audioAssetTracks.isEmpty == true {
			//无音频轨道
			return
		}
		for audioAssetTrack: AVAssetTrack in audioAssetTracks {
			do {
				//音频通道
				if let suggest = suggestTimeRange, audioAssetTrack.timeRange.containsTimeRange(suggest) {
					try audioTrack.insertTimeRange(suggest, of: audioAssetTrack, at: startTime)
				} else if let videoAssetTrack = videoAssetTrack {
					try audioTrack.insertTimeRange(videoAssetTrack.timeRange, of: audioAssetTrack, at: startTime)
				} else {
					try audioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: startTime)
				}
			} catch {
				print(error)
				return
			}
		}
	}

	fileprivate static func transformRotation(from videoTrack: AVAssetTrack) -> (CGAffineTransform, CGSize) {
		// 视频方向修改
		let naturalSize = videoTrack.naturalSize
		var newNaturalSize = naturalSize
		//获取视频方向并修改transform
		let degree = self.degreeFromVideoFileWithURL(videoTrack)
		if degree != 0 {
			var translateToCenter: CGAffineTransform = CGAffineTransform()
			var mixedTransform: CGAffineTransform = CGAffineTransform()
			if degree == 90.0 {
				translateToCenter = CGAffineTransform(translationX: naturalSize.height, y: 0.0)
				mixedTransform = translateToCenter.rotated(by: self.degreesToRadians(degree))
				newNaturalSize = CGSize(width: naturalSize.height, height: naturalSize.width)
			} else if degree == 180.0 {
				translateToCenter = CGAffineTransform(translationX: naturalSize.width, y: naturalSize.height)
				mixedTransform = translateToCenter.rotated(by: self.degreesToRadians(degree))
				newNaturalSize = CGSize(width: naturalSize.width, height: naturalSize.height)
			} else if degree == 270.0 {
				translateToCenter = CGAffineTransform(translationX: 0.0, y: naturalSize.width)
				mixedTransform = translateToCenter.rotated(by: self.degreesToRadians(degree))
				newNaturalSize = CGSize(width: naturalSize.height, height: naturalSize.width)
			}

			return (mixedTransform, newNaturalSize)
		}

		return (videoTrack.preferredTransform, newNaturalSize)
	}

	/// 获取视频方向
	///
	/// - Parameter videoTrack: video track
	/// - Returns: degree
	fileprivate static func degreeFromVideoFileWithURL(_ videoTrack: AVAssetTrack) -> CGFloat {
		var degress: CGFloat = 0.0
		let t: CGAffineTransform = videoTrack.preferredTransform
		if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
			// Portrait
			degress = 90.0
		} else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
			// PortraitUpsideDown
			degress = 270.0
		} else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
			// LandscapeRight
			degress = 0.0
		} else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
			// LandscapeLeft
			degress = 180.0
		}
		return degress
	}

	/// 通过degree获取应该旋转的角度
	///
	/// - Parameter degrees: degree
	/// - Returns: Radians
	fileprivate static func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
		return CGFloat.pi * degrees / 180
	}
}
