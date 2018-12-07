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
    
    override func performWithAsset(_ asset: AVAsset) {
        //step1: 获取视频及音频资源
        var assetVideoTrack: AVAssetTrack?
        var assetAudioTrack: AVAssetTrack?
        
        if asset.tracks(withMediaType: AVMediaTypeVideo).count != 0 {
            assetVideoTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        }
        
        if asset.tracks(withMediaType: AVMediaTypeAudio).count != 0 {
            assetAudioTrack = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
        }

        
        if self.mutableComposition == nil {
            //step2: 创建组合对象并添加视频和音频资源
            self.mutableComposition = AVMutableComposition()
            
            if assetAudioTrack != nil{
                let compositionVideoTrack: AVMutableCompositionTrack = self.mutableComposition!.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: assetVideoTrack!, at: kCMTimeZero)
            }
            
            if assetAudioTrack != nil{
                let compositionAudioTrack: AVMutableCompositionTrack = self.mutableComposition!.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                try! compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: assetAudioTrack!, at: kCMTimeZero)
            }
        }
        //step3:
        
        
    }
    
}
