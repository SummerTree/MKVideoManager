//
//  TLStoryOutput.swift
//  TLStoryCamera
//
//  Created by garry on 2017/6/2.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import GPUImage
import Photos

public enum MKStoryType {
    case video
    case photo
}

class TLStoryOutput: NSObject {
    var type: MKStoryType?
    var url: URL?
	var image: UIImage?
	var audioEnable: Bool = true
    var movieFile: GPUImageMovie?
    var movieWriter: GPUImageMovieWriter?

    func output(filterNamed: String, container: UIImage, callback:@escaping ((URL?, MKStoryType) -> Void)) {
        if type! == .video {
            self.outputVideo(filterNamed: filterNamed, container: container, audioEnable: audioEnable, callback: callback)
        } else {
            self.outputImage(filterNamed: filterNamed, container: container, callback: callback)
        }
    }

    func saveToAlbum(filterNamed: String, container: UIImage, callback:@escaping ((Bool) -> Void)) {
        if type! == .video {
            self.outputVideoToAlbum(filterNamed: filterNamed, container: container, audioEnable: audioEnable, callback: callback)
        } else {
            self.outputImageToAlbum(filterNamed: filterNamed, container: container, callback: callback)
        }
    }

    fileprivate func outputImageToAlbum(filterNamed: String, container: UIImage, callback:@escaping ((Bool) -> Void)) {
        self.outputImage(filterNamed: filterNamed, container: container) { (u, _) in
            if u == nil {
                callback(false)
                return
            }
//            MKProgressHUD.showWatting()
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: u!)
            }, completionHandler: { (_, _) in
                DispatchQueue.main.async {
//                    MKProgressHUD.hideWatting()
//                    MKProgressHUD.show(text: "已保存到相册", delay:1)
                    callback(true)
                }
            })
        }
    }

    fileprivate func outputVideoToAlbum(filterNamed: String, container: UIImage, audioEnable: Bool, callback:@escaping ((Bool) -> Void)) {
        self.outputVideo(filterNamed: filterNamed, container: container, audioEnable: audioEnable) { (u, _) in
            if u == nil {
                callback(false)
                return
            }
//            MKProgressHUD.showWatting()
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: u!)
            }, completionHandler: { (_, _) in
                DispatchQueue.main.async {
//                    MKProgressHUD.hideWatting()
//                    MKProgressHUD.show(text: "已保存到相册", delay:1)
                    callback(true)
                }
            })
        }
    }

    fileprivate func outputImage(filterNamed: String, container: UIImage, callback:@escaping ((URL?, MKStoryType) -> Void)) {
//        MKProgressHUD.showWatting()
        DispatchQueue.global().async {
            var cImg: UIImage?
            if filterNamed.isEmpty == false {
                let picture = GPUImagePicture(image: self.image!)
                let filter = GPUImageCustomLookupFilter(lookupImageNamed: filterNamed)
                picture?.addTarget(filter)
                picture?.processImage()
                filter.useNextFrameForImageCapture()
                guard let img = filter.imageFromCurrentFramebuffer() else {
                    DispatchQueue.main.async(execute: {
//                        MKProgressHUD.hideWatting()
                        callback(nil, .photo)
                    })
                    return
                }
                picture?.removeAllTargets()
                cImg = img
            } else {
                cImg = self.image
            }
            let resultImg = cImg!.imageMontage(img: container, bgColor: UIColor.black, size: MKExportStoryConfiguration.outputPhotoSize).addWatermark(img: MKExportStoryConfiguration.watermarkImage, p: MKExportStoryConfiguration.watermarkPosition)
            let imgData = resultImg.jpegData(compressionQuality: 1)
            guard let exportUrl = TLStoryOutput.outputFilePath(type: .photo, isTemp: false) else {
                DispatchQueue.main.async(execute: {
//                    MKProgressHUD.hideWatting()
                    callback(nil, .photo)
                })
                return
            }
            DispatchQueue.main.async(execute: {
//                MKProgressHUD.hideWatting()
                do {
                    try imgData?.write(to: exportUrl)
                    callback(exportUrl, .photo)
                } catch {
                    callback(nil, .photo)
                }
            })
        }
    }

    fileprivate func outputVideo(filterNamed: String, container: UIImage, audioEnable: Bool, callback:@escaping ((URL?, MKStoryType) -> Void)){
        guard let url = url else {
            return
        }

        let asset = AVAsset(url: url)
        movieFile = GPUImageMovie(asset: asset)
        movieFile?.runBenchmark = false

        let movieFillFilter = TLGPUImageMovieFillFiter()
        movieFillFilter.fillMode = .preserveAspectRatio
        movieFile?.addTarget(movieFillFilter)

        guard let exportUrl = TLStoryOutput.outputFilePath(type: .video, isTemp: false) else {
            callback(nil, .video)
            return
        }

        movieWriter = GPUImageMovieWriter(movieURL: exportUrl, size: MKExportStoryConfiguration.outputVideoSize)

        if audioEnable {
            movieWriter?.shouldPassthroughAudio = audioEnable
            movieFile?.audioEncodingTarget = movieWriter
        }
        movieFile?.enableSynchronizedEncoding(using: movieWriter)

        let imgview = UIImageView(image: container.addWatermark(img: MKExportStoryConfiguration.watermarkImage, p: MKExportStoryConfiguration.watermarkPosition))

        let uielement = GPUImageUIElement(view: imgview)

        let landBlendFilter = TLGPUImageAlphaBlendFilter()
        landBlendFilter.mix = 1
        let progressFilter = filterNamed.isEmpty ? GPUImageFilter() : GPUImageCustomLookupFilter(lookupImageNamed: filterNamed)

        movieFillFilter.addTarget(progressFilter as? GPUImageInput)
        progressFilter.addTarget(landBlendFilter)
        uielement?.addTarget(landBlendFilter)
        landBlendFilter.addTarget(movieWriter!)

        progressFilter.frameProcessingCompletionBlock = { output, time in
            uielement?.update(withTimestamp: time)
        }

        movieWriter?.startRecording()
        movieFile?.startProcessing()

//        MKProgressHUD.showWatting()
        self.movieWriter?.completionBlock = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            movieFillFilter.removeAllTargets()
            landBlendFilter.removeAllTargets()
            progressFilter.removeAllTargets()
            uielement?.removeAllTargets()
            strongSelf.movieFile?.removeAllTargets()
            strongSelf.movieWriter?.finishRecording()
            strongSelf.movieFile?.audioEncodingTarget = nil
            DispatchQueue.main.async {
//                MKProgressHUD.hideWatting()
                callback(exportUrl, .video)
            }
        }
        self.movieWriter?.failureBlock = { x in
//            MKProgressHUD.hideWatting()
//            MKProgressHUD.show(text: "Failure", delay: 0.2)
        }
    }

	static func outputFilePath(type: MKStoryType, isTemp: Bool) -> URL? {
        do {
            try? FileManager.default.createDirectory(atPath: type == .video ? MKExportStoryConfiguration.videoPath! : MKExportStoryConfiguration.photoPath!, withIntermediateDirectories: true, attributes: nil)
            if type == .video {
                let fileName = isTemp ? "mov_tmp.mp4" : "mov_out.mp4"
                let url = URL(fileURLWithPath: "\(MKExportStoryConfiguration.videoPath!)/\(fileName)")
                try? FileManager.default.removeItem(at: url)
                return url
            }
            if type == .photo {
                let fileName = isTemp ? "pic_tmp.png" : "pic_out.png"
                let url = URL(fileURLWithPath: "\(MKExportStoryConfiguration.photoPath!)/\(fileName)")
                try? FileManager.default.removeItem(at: url)
                return url
            }
        }
        return nil
    }
	func reset() {
        movieFile?.audioEncodingTarget = nil
        movieFile = nil
        movieWriter = nil
        image = nil
        audioEnable = true
    }
}
