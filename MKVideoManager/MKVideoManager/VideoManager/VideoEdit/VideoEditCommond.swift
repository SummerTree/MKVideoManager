//
//  VideoEditCommond.swift
//  Monkey
//
//  Created by holla on 2019/5/18.
//  Copyright © 2019 Monkey Squad. All rights reserved.
//

import Foundation
import AVFoundation

enum CompositionType: String {
	case Save
	case MomentSaveWithNoWaterImage
	case MomentSaveWithWaterImage
	case MomentShareSnapChat
	case MomentShareInstagramWhatsApp
	case FamousSaveWithNoWaterImage
	case FomousSaveWithWaterImage
	case FamousShareSnapChat
	case FamousShareInstagramAndWhatsApp
}

protocol VideoEditCommandDelegate: NSObjectProtocol {
	func videoEdit(wit progress: Double, compositionType: CompositionType)
	func videoEdit(wit status: VideoExportCommand.FinishStatus, compositionType: CompositionType)
}

class VideoEditCommand: NSObject {
	deinit {
		print("VideoEditCommand deinit")
	}

	var outputVideoSetting: [String: Any]?

	var outputAudioSetting: [String: Any]?

	var exportUrl: URL?

	var exportFileType: AVFileType?
	
	var exporter: VideoExportCommand?
	
	var compositionType: CompositionType = .Save

	weak var videoEditDelegate: VideoEditCommandDelegate?

	func compositionVideoAndExport(with localUrl: URL, waterImage: UIImage? = nil, compositionType: CompositionType = .Save, callback: @escaping OperationFinishHandler) {
		let (mixcomposition, videoComposition, audioMix) = VideoCompositionCommand.compostionVideo(videoUrl: localUrl, waterImage: waterImage)
		guard let mixCom = mixcomposition, let videoCom = videoComposition else {
			callback(nil)
			return
		}
	
		self.compositionType = compositionType
		let exporter = VideoExportCommand(customQueue: self.compositionType.rawValue)
		exporter.exportDelegate = self
		self.configureExport(with: exporter)
		VideoWatermarkCommond.applyViewEffectsToCompostion(videoCom, waterImage, videoCom.renderSize)
		exporter.exportVideo(with: mixCom, videoComposition: videoCom, audioMixTools: audioMix, callback: callback)
		self.exporter = exporter
	}

	func compositionVideoAndExport(with commonImage: UIImage?, firstUrl: URL, maskUrl: URL, maskScale: CGFloat, maskOffset: CGPoint, compositionType: CompositionType = .Save, callback: @escaping OperationFinishHandler) {
		let (mixcomposition, videoComposition, audioMix) = VideoCompositionCommand.compositionStoryWithSys(firstUrl, maskUrl, maskScale: maskScale, maskOffset: maskOffset)

		guard let mixCom = mixcomposition, let videoCom = videoComposition else {
			callback(nil)
			return
		}
		
		if let lastExport = self.exporter, lastExport.isWriting == true {
			TimeLog.logTime(logString: "exporter is writing, wait please")
			return
		}
		
		self.compositionType = compositionType
		
		let exporter = VideoExportCommand(customQueue: self.compositionType.rawValue)
		self.configureExport(with: exporter)
		exporter.exportDelegate = self
		VideoWatermarkCommond.applyFamousToCompostion(with: videoCom, commonWaterImage: commonImage, size: videoCom.renderSize)
		exporter.exportVideo(with: mixCom, videoComposition: videoCom, audioMixTools: audioMix, callback: callback)
		self.exporter = exporter
	}
	
	func cancel() {
		self.exporter?.cancelWriterProgress()
	}

	fileprivate func configureExport(with exporter: VideoExportCommand) {
		if let videoSetting = self.outputVideoSetting {
			exporter.videoSetting = videoSetting
		}
		if let audioSetting = self.outputAudioSetting {
			exporter.audioSetting = audioSetting
		}

		if let fileType: AVFileType = self.exportFileType {
			exporter.exportFileType = fileType
		}

		if let url = self.exportUrl {
			exporter.exportUrl = url
		}
	}

	private func getDuration(_ videoUrl: URL) -> Double {
		let opts = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: false)]
		let asset = AVURLAsset(url: videoUrl, options: opts)
		let seconds = Double(asset.duration.value) / Double(asset.duration.timescale)
		return seconds
	}
}

extension VideoEditCommand: VideoExportCommandDelegate {
	func videoExportProgress(videoExporter: VideoExportCommand, progress: Double) {
		DispatchQueue.main.async {
			self.videoEditDelegate?.videoEdit(wit: progress, compositionType: self.compositionType)
//			TimeLog.logTime(logString: "Video exportProgress: \(progress)")
		}
	}
	
	func videoExportCompleted(videoExporter: VideoExportCommand, status: VideoExportCommand.FinishStatus) {
		TimeLog.logTime(logString: "Finish videoExport status: \(status.rawValue)")
		self.videoEditDelegate?.videoEdit(wit: status, compositionType: self.compositionType)
	}
}
