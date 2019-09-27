//
//  MKVideoManager.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/16.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class MKVideoManager: NSObject {
    static let `default` = MKVideoManager()
    private var movieFilter: GPUImageMovie?
    private var movieWriter: GPUImageMovieWriter?
    private var progressFilter: GPUImageBrightnessFilter?
    private var inputElement: GPUImageUIElement?
	var exportUrl: URL = {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("story_capture_edit_end_temp.mp4")
    }()

    func exportWaterImageVideo(_ watermarkImage: UIImage, _ videoUrl: URL) {
        let opts: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(booleanLiteral: false)]
        let asset = AVURLAsset(url: videoUrl, options: opts)
		let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let movieSize = assetVideoTrack.naturalSize
//        let mp4Url = URL.init(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "mp4")!)
//        movieFilter = GPUImageMovie.init(url: mp4Url)
        movieFilter = GPUImageMovie(asset: asset)
        movieFilter?.runBenchmark = false
        //        movieFilter?.playAtActualSpeed = false

        let imageView = UIImageView()
        imageView.image = watermarkImage.imageMontage()
        imageView.bounds = CGRect(origin: CGPoint.zero, size: movieSize)
        imageView.backgroundColor = UIColor.clear
        imageView.center = CGPoint(x: movieSize.width / 2, y: movieSize.height / 2)
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: movieSize.width, height: movieSize.height))
        bgView.backgroundColor = UIColor.clear
        bgView.addSubview(imageView)
        inputElement = GPUImageUIElement(view: bgView)
        //alphaBlendFilter
        let blendFilter = GPUImageAlphaBlendFilter()
        blendFilter.mix = 1.0
        deleteExistingFile(url: self.exportUrl)
        print("export path : \(exportUrl)")
        //videoSetting
        //        movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl, size: movieSize, fileType: AVFileTypeMPEG4, outputSettings: StoryCaptureConfiguration.videoSetting)
        //        movieWriter?.setHasAudioTrack(true, audioSettings: StoryCaptureConfiguration.audioSetting)
        movieWriter = GPUImageMovieWriter(movieURL: exportUrl, size: movieSize)
        //        movieWriter = GPUImageMovieWriter.init(movieURL: exportUrl, size: movieSize, fileType: AVFileTypeQuickTimeMovie, outputSettings: nil)
        movieWriter?.shouldPassthroughAudio = true
		movieWriter?.assetWriter.movieFragmentInterval = CMTime.invalid
        movieFilter?.audioEncodingTarget = movieWriter
        movieFilter?.enableSynchronizedEncoding(using: movieWriter)
        progressFilter = GPUImageBrightnessFilter()
        progressFilter?.brightness = 0.0
        //
        movieFilter?.addTarget(progressFilter)
        progressFilter?.addTarget(blendFilter)
        inputElement?.addTarget(blendFilter)
//        progressFilter?.addTarget(movieWriter)
        blendFilter.addTarget(movieWriter)
        // must set
        progressFilter?.frameProcessingCompletionBlock = { out, time in
            print("time: \(time)")
            self.inputElement?.update()
        }
        movieWriter?.startRecording()
        movieFilter?.startProcessing()
        // success
        movieWriter?.completionBlock = {
            //            self.progressFilter?.removeAllTargets()
            self.movieWriter?.finishRecording()
//            DispatchQueue.main.sync {
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.exportUrl)
//                }) { saved, error in
//                    print("saved")
//                }
//            }
        }

        // failed
        movieWriter?.failureBlock = { error in
            //            self.progressFilter?.removeTarget(self.movieWriter)
            self.movieWriter?.finishRecording()
        }
    }
    func deleteExistingFile(url: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
    }
}
extension UIView {
    public func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
