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
	
	static private var exportUrl: URL = {
		return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("export_temp.mp4")
	}()
    
    override func performWithAsset(_ asset: AVAsset) {
        //step1: 获取视频及音频资源
        var assetVideoTrack: AVAssetTrack?
        var assetAudioTrack: AVAssetTrack?
        
		if asset.tracks(withMediaType: AVMediaType.video).count != 0 {
			assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        }
        
		if asset.tracks(withMediaType: AVMediaType.audio).count != 0 {
			assetAudioTrack = asset.tracks(withMediaType: AVMediaType.audio)[0]
        }

        
        if self.mutableComposition == nil {
            //step2: 创建组合对象并添加视频和音频资源
            self.mutableComposition = AVMutableComposition()
            
            if assetAudioTrack != nil{
				let compositionVideoTrack: AVMutableCompositionTrack = self.mutableComposition!.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
				try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: assetVideoTrack!, at: CMTime.zero)
            }
            
            if assetAudioTrack != nil{
				let compositionAudioTrack: AVMutableCompositionTrack = self.mutableComposition!.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
				try! compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: assetAudioTrack!, at: CMTime.zero)
            }
        }
        //step3:
        
        
    }
	
	static private func compositionStoryWithSys(_ watermarkImage: UIImage, _ videoUrl: URL, callback:@escaping ((URL?) -> Void)){
		//1 初始化视频媒体文件
		let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber.init(value: false)]
		let asset = AVURLAsset.init(url: videoUrl, options: opts)
		let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
		let startTime = CMTimeMakeWithSeconds(0, preferredTimescale: asset.duration.timescale)
		let seconds = Float(asset.duration.value) / Float(asset.duration.timescale)
		let endTime = CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: asset.duration.timescale)
		let naturalSize = assetVideoTrack.naturalSize
		
		//2 创建AVMutableComposition实例. apple developer 里边的解释 【AVMutableComposition is a mutable subclass of AVComposition you use when you want to create a new composition from existing assets. You can add and remove tracks, and you can add, remove, and scale time ranges.】
		let mixComposition = AVMutableComposition()
		
		//3 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
		let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
		let videoAssetTracks = asset.tracks(withMediaType: AVMediaType.video)
		if videoAssetTracks.count > 0{
			do{
				//把视频轨道数据加入到可变轨道中 这部分可以做视频裁剪TimeRange
				try videoTrack?.insertTimeRange(CMTimeRangeFromTimeToTime(start: startTime, end: endTime), of: videoAssetTracks[0], at: CMTime.zero)
			}catch{
				print(error)
				return
			}
		}else{
			callback(nil)
			return
		}
		
		
		let audioAsset = AVURLAsset.init(url: videoUrl, options: opts)
		//音频采集通道
		let audioAssetTracks = audioAsset.tracks(withMediaType: AVMediaType.audio)
		if audioAssetTracks.count > 0{
			do {
				//音频通道
				let audioAssetTrack = audioAsset.tracks(withMediaType: AVMediaType.audio).first
				let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
				try audioTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: endTime), of: audioAssetTrack!, at: CMTime.zero)
			} catch {
				print(error)
				return
			}
		}
		
		//3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
		let mainInstruction = AVMutableVideoCompositionInstruction()
		mainInstruction.timeRange = CMTimeRangeFromTimeToTime(start: CMTime.zero, end: videoTrack?.timeRange.duration ?? CMTime.zero)
		
		// 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
		guard let videotrack = videoTrack else { return }
		let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videotrack)
		
		let videoAssetTrack = asset.tracks(withMediaType: AVMediaType.video).first
		// 视频方向修改
		var newNaturalSize = naturalSize
		//获取视频方向并修改transform
		let degree = self.degreeFromVideoFileWithURL(videoAssetTrack!)
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
			
			videoLayerInstruction.setTransform(mixedTransform, at: CMTime.zero)
		}
		videoLayerInstruction.setOpacity(0.0, at: endTime)
		
		// 3.3 - Add instructions
		mainInstruction.layerInstructions = [videoLayerInstruction]
		
		//AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
		let mainCompositionInst = AVMutableVideoComposition()
		
		
		//输出视频尺寸，视频的宽和高都要是16的倍数，不然经过AVFoundation的API合成后系统会自动对尺寸进行校正，不足的地方会以绿边的形式进行填充。（视频导出后有绿色边缘的问题）
		var offsetW = Int(newNaturalSize.width)%16
		var offsetH = Int(newNaturalSize.height)%16
		
		offsetW = (offsetW == 0) ? 0 : 16 - offsetW
		offsetH = (offsetH == 0) ? 0 : 16 - offsetH
		
		//        mainCompositionInst.renderSize = newNaturalSize
		mainCompositionInst.renderSize = CGSize.init(width: newNaturalSize.width + CGFloat(offsetW), height: newNaturalSize.height + CGFloat(offsetH))
		mainCompositionInst.instructions = [mainInstruction]
		
		//WARNING: 如果frameDuration比这里设置的更小
		mainCompositionInst.frameDuration = CMTimeMake(value: 1, timescale: 30)
		
		//水印
		self.applyViewoEffectsToCompostion(mainCompositionInst, watermarkImage, newNaturalSize)
		self.deleteExistingFile(url: self.exportUrl)
		// 4 - 输出视频
		let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
		exporter?.outputURL = self.exportUrl
		exporter?.outputFileType = AVFileType.mp4
		exporter?.shouldOptimizeForNetworkUse = true
		exporter?.videoComposition = mainCompositionInst
		exporter?.exportAsynchronously(completionHandler: {
			if exporter?.status == AVAssetExportSession.Status.completed {
				guard let err = exporter?.error else{
					callback(exporter?.outputURL)
					return
				}
				print("err: \(err)")
				callback(nil)
			}
			if exporter?.status == AVAssetExportSession.Status.cancelled {
				callback(nil)
			}else{
				callback(nil)
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
