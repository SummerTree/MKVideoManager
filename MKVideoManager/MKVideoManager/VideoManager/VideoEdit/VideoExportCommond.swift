//
//  MKVideoExport.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import VideoToolbox

typealias OperationFinishHandler = (_ url: URL?) -> Void

class VideoExportCommand: NSObject {
	deinit {
		print("VideoExportCommand deinit")
	}

	enum ExportType: Int {
		case export
		case writer
	}
	
	var videoSetting: [String: Any] = [
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

	var audioSetting: [String: Any] = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVNumberOfChannelsKey: 2,
		AVSampleRateKey: 44100,
		AVEncoderBitRateKey: 64000
	]

	var exportFileType: AVFileType = .mp4

	var exportUrl: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("export_commond_temp.mp4")

	private var finishedHandler: OperationFinishHandler?
	private var assetReader: AVAssetReader?
	private var assetWriter: AVAssetWriter?

	private var assetReaderAudioOutput: AVAssetReaderAudioMixOutput?
	private var assetReaderVideoOutput: AVAssetReaderVideoCompositionOutput?
	private var assetWriterAudioOutput: AVAssetWriterInput?
	private var assetWriterVideoOutput: AVAssetWriterInput?

//	private lazy var mainSerializetionQueue = DispatchQueue(label: "com.monkey.writer.exportQueue")
//	private lazy var videoQueue: DispatchQueue = DispatchQueue(label: "com.monkey.writer.exportVideoQueue")
//	private lazy var audioQueue: DispatchQueue = DispatchQueue(label: "com.monkey.writer.exportAudioQueue")
//	private lazy var dispatchGroup: DispatchGroup = DispatchGroup()
	private var mainSerializetionQueue = DispatchQueue(label: "com.monkey.writer.exportQueue")
	private var videoQueue: DispatchQueue = DispatchQueue(label: "com.monkey.writer.exportVideoQueue")
	private var audioQueue: DispatchQueue = DispatchQueue(label: "com.monkey.writer.exportAudioQueue")
	private var dispatchGroup: DispatchGroup = DispatchGroup()
	private var audioFinished: Bool = false
	private var videoFinished: Bool = false
	private var cancelled: Bool = false
	private var sourceDuration: CMTime = CMTime.zero
	
	private var testString: String = ""
	//想要并发的合成多个视频时，为export设置不同的queue name
	var customQueueName: String?

	init(customQueue: String? = nil) {
		self.customQueueName = customQueue
	}

	func exportVideo(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix?, exportType: ExportType, callback: OperationFinishHandler?) {
		switch exportType {
		case .export:
			self.exportVideoSession(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools, callback: callback)
		case .writer:
			self.exportVideoWriter(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools, callback: callback)
		}
	}

	func cancelWriterProgress() {
		self.cancel()
	}
}

extension VideoExportCommand {
	fileprivate func exportVideoSession(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil, callback: OperationFinishHandler?) {
		self.deleteExistingFile(url: self.exportUrl)
		guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
			callback?(nil)
			return
		}
		exporter.outputURL = self.exportUrl
		exporter.outputFileType = AVFileType.mp4
		exporter.shouldOptimizeForNetworkUse = true
		exporter.videoComposition = videoComposition
		if let audioMix = audioMixTools {
			exporter.audioMix = audioMix
		}

		exporter.exportAsynchronously(completionHandler: {
			if exporter.status == AVAssetExportSession.Status.completed {
				guard let err = exporter.error else {
					callback?(self.exportUrl)
					return
				}
				print("err: \(err)")
				callback?(nil)
			} else if exporter.status == AVAssetExportSession.Status.failed {
				callback?(nil)
			}
			print(exporter.status)
		})
	}
	
	private func setupQueue(queue: String? = nil) {
		self.testString = String(describing: queue)
		self.mainSerializetionQueue = DispatchQueue(label: "com.monkey.writer.export\(String(describing: queue))")
		self.videoQueue = DispatchQueue(label: "com.monkey.writer.exportVideo\(String(describing: queue))")
		self.audioQueue = DispatchQueue(label: "com.monkey.writer.exportAudio\(String(describing: queue))")
		self.dispatchGroup = DispatchGroup()
		self.exportUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(String(describing: queue)).mp4")
	}

	fileprivate func exportVideoWriter(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil, callback: OperationFinishHandler?) {
		self.cancelled = false
		self.finishedHandler = callback
		if let customQueue = self.customQueueName {
			self.setupQueue(queue: customQueue)
		}
		mixComposition.loadValuesAsynchronously(forKeys: ["tracks"]) {[weak self] in
			guard let `self` = self else { return }
			self.mainSerializetionQueue.async(execute: {
				if self.cancelled == true {
					return
				}
				var success = true
				var error: NSError?
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

	fileprivate func cancel() {
		TimeLog.logTime(logString: "canceled")
		// Handle cancellation asynchronously, but serialize it with the main queue.
		self.mainSerializetionQueue.async {
			// If we had audio data to reencode, we need to cancel the audio work.
			if self.assetWriterAudioOutput != nil {
				// Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
				if self.audioFinished == false {
					self.audioFinished = true
					self.assetWriterAudioOutput?.markAsFinished()
					// Leave the dispatch group since the audio work is finished now.
					self.dispatchGroup.leave()
				}
			}

			if self.assetWriterVideoOutput != nil {
				// Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
				let oldFinished = self.videoFinished
				self.videoFinished = true
				if oldFinished == false {
					self.assetWriterVideoOutput?.markAsFinished()
					// Leave the dispatch group, since the video work is finished now.
					self.dispatchGroup.leave()
				}
			}
		}

		self.cancelled = true
	}

	fileprivate func startAssetWriter() -> Bool {
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
				if completedOrFailed == true && self.cancelled == false {
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
						let preTime = CMSampleBufferGetPresentationTimeStamp( sampleBuffer)

						let preTimeSeconds = CMTimeGetSeconds(preTime)
						let totalTimeSeconds = CMTimeGetSeconds(self.sourceDuration)
						let progress: Double = Double(preTimeSeconds / totalTimeSeconds)
						TimeLog.logTime(logString: self.testString)
						TimeLog.logTime(logString: "Finish exportProgress: \(progress)")
					} else {
						completedOrFailed = true
					}
				}
				if completedOrFailed == true && self.cancelled == false {
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
		dispatchGroup.notify(queue: self.mainSerializetionQueue) {
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
						self.readingAndWritingDidFinish(with: true)
					})
				}
			}
		}
		return startSuccess
	}

	fileprivate func readingAndWritingDidFinish(with success: Bool) {
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
			print(self.testString)
			TimeLog.logTime(logString: "Finish videoExport")
			if success == true {
				TimeLog.logTime(logString: "success videoExport")
				self.finishedHandler?(self.exportUrl)
			} else {
				TimeLog.logTime(logString: "failed videoExport")
				self.finishedHandler?(nil)
			}
			self.finishedHandler = nil
		}
	}

	fileprivate func setupAssetReaderAndAssetWriter(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil) -> Bool {
		guard self.getAssetsReader(with: mixComposition, videoComposition: videoComposition, audioMixTools: audioMixTools) != nil, self.getAssetWriter() != nil else {
			return false
		}
		return true
	}

	fileprivate func getAssetsReader(with mixComposition: AVComposition, videoComposition: AVVideoComposition, audioMixTools: AVAudioMix? = nil) -> AVAssetReader? {
		var assetReader: AVAssetReader
		do {
			try assetReader = AVAssetReader(asset: mixComposition)
		} catch {
			print(error.localizedDescription)
			return nil
		}
		self.sourceDuration = mixComposition.duration
		let videoTracks = mixComposition.tracks(withMediaType: AVMediaType.video)
		let videoReaderSetting: [String: Any] = [
			String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
		]
		let videoCompositionOutput: AVAssetReaderVideoCompositionOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: videoReaderSetting)
		videoCompositionOutput.videoComposition = videoComposition
		videoCompositionOutput.alwaysCopiesSampleData = false

		if assetReader.canAdd(videoCompositionOutput) {
			assetReader.add(videoCompositionOutput)
			self.assetReaderVideoOutput = videoCompositionOutput
		}

		let audioTracks = mixComposition.tracks(withMediaType: AVMediaType.audio)
		if audioTracks.isEmpty == false {
			let audioMixOutput: AVAssetReaderAudioMixOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)

			if let audioMix = audioMixTools {
				audioMixOutput.audioMix = audioMix
			}

			audioMixOutput.alwaysCopiesSampleData = false

			if assetReader.canAdd(audioMixOutput) {
				assetReader.add(audioMixOutput)
				self.assetReaderAudioOutput = audioMixOutput
			}
		}

		self.assetReader = assetReader
		return assetReader
	}

	fileprivate func getAssetWriter() -> AVAssetWriter? {
		var assetWriter: AVAssetWriter
		do {
			try assetWriter = AVAssetWriter(outputURL: self.exportUrl, fileType: self.exportFileType)
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

	fileprivate func deleteExistingFile(url: URL) {
		let fileManager = FileManager.default
		do {
			try fileManager.removeItem(at: url)
		} catch {
			print(#function)
			print(error.localizedDescription)
		}
	}
}
