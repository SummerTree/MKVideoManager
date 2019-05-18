//
//  MKVideoExport.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import VideoToolbox

class MKVideoExportCommand: NSObject {
	enum ExportType: Int {
		case export
		case writer
	}

	private var videoSetting: [String: Any] = [
		AVVideoCodecKey: AVVideoCodecH264,
		AVVideoWidthKey: 720,
		AVVideoHeightKey: 1280,
		AVVideoCompressionPropertiesKey: [
			AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
			// 码率
			AVVideoAverageBitRateKey: 1800000,
			AVVideoExpectedSourceFrameRateKey: 30
		]
	]
	
	private var audioSetting: [String: Any] = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVNumberOfChannelsKey: 2,
		AVSampleRateKey: 44100,
		AVEncoderBitRateKey: 64000
	]
	
	private var exportVideoSize: CGSize = CGSize.init(width: 720, height: 1280)
	
	private var exportUrl: URL = {
		return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("export_temp.mp4")
	}()
	
	private var exportFileType: AVFileType {
		return .mp4
	}
	
	
	var finishedHandler: OperationFinishHandler?
	var assetReader: AVAssetReader?
	var assetWriter: AVAssetWriter?
	
	var assetReaderAudioOutput: AVAssetReaderAudioMixOutput?
	var assetReaderVideoOutput: AVAssetReaderVideoCompositionOutput?
	var assetWriterAudioOutput: AVAssetWriterInput?
	var assetWriterVideoOutput: AVAssetWriterInput?
	
	lazy var mainSerializetionQueue = DispatchQueue.init(label: "com.monkey.writer.exportQueue")
	lazy var videoQueue: DispatchQueue = DispatchQueue.init(label: "com.monkey.writer.exportVideoQueue")
	lazy var audioQueue: DispatchQueue = DispatchQueue.init(label: "com.monkey.writer.exportAudioQueue")
	lazy var dispatchGroup: DispatchGroup = DispatchGroup.init()
	var audioFinished: Bool = false
	var videoFinished: Bool = false
	var cancelled: Bool = false
	
	func exportVideo(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix?, exportType: ExportType, callback: OperationFinishHandler?) {
		switch exportType {
		case .export:
			self.exportVideoSession(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools, callback: callback)
			break
		case .writer:
			self.exportVideoWriter(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools, callback: callback)
			break
		}
//		self.finishedHandler = callback
	}
	
	private func exportVideoSession(with mixComposition: AVComposition, videoComposition:
		AVVideoComposition, audioMixTools: AVAudioMix? = nil, callback: OperationFinishHandler?) {
		
		self.deleteExistingFile(url: self.exportUrl)
		let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
		exporter?.outputURL = self.exportUrl
		exporter?.outputFileType = AVFileType.mp4
		exporter?.shouldOptimizeForNetworkUse = true
		exporter?.videoComposition = videoComposition
		if let audioMix = audioMixTools {
			exporter?.audioMix = audioMix
		}
		
		exporter?.exportAsynchronously(completionHandler: {
			if exporter?.status == AVAssetExportSession.Status.completed {
				guard let err = exporter?.error else{
					callback?(self.exportUrl)
					return
				}
				print("err: \(err)")
				callback?(nil)
			} else {
				print(exporter?.status ?? "----")
			}
		})
	}
	
	
	
	private func exportVideoWriter(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil, callback: OperationFinishHandler?) {
		
		self.cancelled = false
		self.finishedHandler = callback
		mixComposition.loadValuesAsynchronously(forKeys: ["tracks"]) {[weak self] in
			guard let `self` = self else { return }
			self.mainSerializetionQueue.async(execute: {
				if self.cancelled ==  true {
					return
				}
				var success = true
				var error: NSError? = nil
				// Check for success of loading the assets tracks.
				let status: AVKeyValueStatus = mixComposition.statusOfValue(forKey: "tracks", error: &error)
				success = (status == .loaded)
				if success {
					// If the tracks loaded successfully, make sure that no file exists at the output path for the asset writer.
					self.deleteExistingFile(url: self.exportUrl)
				}
				
				if success {
					success = self.setupAssetReaderAndAssetWriter(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools)
				}
				
				if success {
					success = self.startAssetWriter()
				}
				
				if success == false {
					self.readingAndWritingDidFinish(with: success)
				}
			})
		}
	}
	
	func cancel() {
		// Handle cancellation asynchronously, but serialize it with the main queue.
		self.mainSerializetionQueue.async {
			// If we had audio data to reencode, we need to cancel the audio work.
			if let _ = self.assetWriterAudioOutput {
				// Handle cancellation asynchronously again, but this time serialize it with the audio queue.
				self.audioQueue.async {
					// Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
					let oldFinished = self.audioFinished
					self.audioFinished = true
					if oldFinished == false {
						self.assetWriterAudioOutput?.markAsFinished()
					}
					
					self.dispatchGroup.leave()
				}
			}
			
			// Handle cancellation asynchronously again, but this time serialize it with the video queue.
			if let _ = self.assetWriterVideoOutput {
				self.videoQueue.async {
					// Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
					let oldFinished = self.videoFinished
					self.videoFinished = true
					if oldFinished == false {
						self.assetWriterVideoOutput?.markAsFinished()
					}
					 // Leave the dispatch group, since the video work is finished now.
					self.dispatchGroup.leave()
				}
			}
			// Set the cancelled Boolean property to YES to cancel any work on the main queue as well.
			self.cancelled = true
		}
		
		
		self.cancelled = true
	}
	
	private func startAssetWriter() -> Bool {
		guard let reader = self.assetReader, let writer = self.assetWriter else {
			return false
		}
		var startSuccess: Bool = true
		if reader.startReading(), writer.startWriting() {
			startSuccess = true
		} else {
			// start error
			print(reader.error?.localizedDescription as Any)
			print(writer.error?.localizedDescription as Any)
			startSuccess = false
		}
		
		if startSuccess == false {
			return false
		}
		
		// writer session start
		writer.startSession(atSourceTime: CMTime.zero)
		
		
		// audio progress
		if let writerAudioInput = self.assetWriterAudioOutput {
			// If there is audio to reencode, enter the dispatch group before beginning the work.
			self.dispatchGroup.enter()
			// Specify the block to execute when the asset writer is ready for audio media data, and specify the queue to call it on.
			writerAudioInput.requestMediaDataWhenReady(on: self.audioQueue) {
				// Because the block is called asynchronously, check to see whether its task is complete.
				if self.audioFinished {
					return
				}
				
				var completedOrFailed: Bool = false
				while writerAudioInput.isReadyForMoreMediaData && completedOrFailed == false {
					// Get the next audio sample buffer, and append it to the output file.
					if let sampleBuffer: CMSampleBuffer = self.assetReaderAudioOutput?.copyNextSampleBuffer(), let success = self.assetWriterAudioOutput?.append(sampleBuffer) {
						completedOrFailed = !success
					} else {
						completedOrFailed = true
					}
				}
				if completedOrFailed == true {
					// Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the audio work has finished).
					let oldFinished: Bool = self.audioFinished
					self.audioFinished = true
					if oldFinished == false {
						self.assetWriterAudioOutput?.markAsFinished()
					}
					self.dispatchGroup.leave()
				}
			}
		}
		
		
		if let writerVideoInput = self.assetWriterVideoOutput {
			// If we had video to reencode, enter the dispatch group before beginning the work.
			dispatchGroup.enter()
			// Specify the block to execute when the asset writer is ready for video media data, and specify the queue to call it on.
			writerVideoInput.requestMediaDataWhenReady(on: videoQueue) {
				if self.videoFinished == true {
					return
				}
				
				var completedOrFailed: Bool = false
				// If the task isn't complete yet, make sure that the input is actually ready for more media data.
				while writerVideoInput.isReadyForMoreMediaData && completedOrFailed == false {
					if let sampleBuffer: CMSampleBuffer = self.assetReaderVideoOutput?.copyNextSampleBuffer(), let success = self.assetWriterVideoOutput?.append(sampleBuffer) {
						completedOrFailed = !success
					} else {
						completedOrFailed = true
					}
				}
				if completedOrFailed == true {
					// Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the audio work has finished).
					let oldFinished: Bool = self.videoFinished
					self.videoFinished = true
					if oldFinished == false {
						self.assetWriterVideoOutput?.markAsFinished()
					}
					self.dispatchGroup.leave()
				}
			}
		}
		
		// Set up the notification that the dispatch group will send when the audio and video work have both finished.
		dispatchGroup.notify(queue: DispatchQueue.main) {
			// Check to see if the work has finished due to cancellation.
			if self.cancelled == true {
				self.readingAndWritingDidFinish(with: false)
			} else {
				// If cancellation didn't occur, first make sure that the asset reader didn't fail.
				if reader.status == .failed {
					print(reader.error?.localizedDescription as Any)
					self.readingAndWritingDidFinish(with: false)
				} else {
					writer.finishWriting(completionHandler: {
						
					})
					self.readingAndWritingDidFinish(with: true)
				}
			}
		}
		return startSuccess
	}
	
	private func readingAndWritingDidFinish(with success: Bool) {
		if success == false {
			self.assetReader?.cancelReading()
			self.assetWriter?.cancelWriting()
		} else {
			// Reencoding was successful, reset booleans.
			self.cancelled = false
			self.videoFinished = false
			self.audioFinished = false
		}
		
		DispatchQueue.main.async {
			// Handle any UI tasks here related to failure or success.
			print("finished")
			if success == true {
				self.finishedHandler?(self.exportUrl)
			} else {
				self.finishedHandler?(nil)
			}
			self.finishedHandler = nil
		}
	}
	
	private func setupAssetReaderAndAssetWriter(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil) -> Bool {
		guard let _ = self.getAssetsReader(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools), let _ = self.getAssetWriter() else {
			return false
		}
		return true
	}
	
	private func getAssetsReader(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil) -> AVAssetReader? {
		var assetReader: AVAssetReader
		do {
			try assetReader = AVAssetReader.init(asset: mixComposition)
		} catch  {
			print(error.localizedDescription)
			return nil
		}
		let audioTracks = mixComposition.tracks(withMediaType: AVMediaType.audio)
		let audioMixOutput: AVAssetReaderAudioMixOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)
		
		let videoTracks = mixComposition.tracks(withMediaType: AVMediaType.video)
		let videoReaderSetting: [String: Any] = [
			String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
		]
		let videoCompositionOutput: AVAssetReaderVideoCompositionOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: videoReaderSetting)
		
		if let audioMix = audioMixTools {
			audioMixOutput.audioMix = audioMix
		}
		
		audioMixOutput.alwaysCopiesSampleData = false
		videoCompositionOutput.videoComposition = videoComposition
		videoCompositionOutput.alwaysCopiesSampleData = false
		
		if assetReader.canAdd(audioMixOutput) {
			assetReader.add(audioMixOutput)
			self.assetReaderAudioOutput = audioMixOutput
		}
		
		if assetReader.canAdd(videoCompositionOutput) {
			assetReader.add(videoCompositionOutput)
			self.assetReaderVideoOutput = videoCompositionOutput
		}
		
		self.assetReader = assetReader
		return assetReader
	}
	
	private func getAssetWriter() -> AVAssetWriter? {
		var assetWriter: AVAssetWriter
		do {
			try assetWriter = AVAssetWriter.init(outputURL: self.exportUrl, fileType: self.exportFileType)
		} catch {
			print(error.localizedDescription)
			return nil
		}
		
		let videoWriterInput: AVAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: self.videoSetting, sourceFormatHint: nil)
		
		let audioWriterInput: AVAssetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: self.audioSetting, sourceFormatHint: nil)
		
		if assetWriter.canAdd(videoWriterInput) {
			assetWriter.add(videoWriterInput)
			self.assetWriterVideoOutput = videoWriterInput
		}
		
		if assetWriter.canAdd(audioWriterInput) {
			assetWriter.add(audioWriterInput)
			self.assetWriterAudioOutput = audioWriterInput
		}
		self.assetWriter = assetWriter
		return assetWriter
	}
	
	private func deleteExistingFile(url: URL) {
		let fileManager = FileManager.default
		do {
			try fileManager.removeItem(at: url)
		}
		catch {
			print(#function)
			print(error.localizedDescription)
		}
	}
}
