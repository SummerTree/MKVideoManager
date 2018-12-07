//
//  MKVideoCommand.swift
//  MKVideoManager
//
//  Created by holla on 2018/11/19.
//  Copyright © 2018 xiaoxiang. All rights reserved.
//

import Foundation
import AVFoundation

class MKVideoCommand: NSObject {
    static let AVSEEditCommandCompletionNotification: String = "AVSEEditCommandCompletionNotification"
    static let AVSEExportCommandCompletionNotification: String = "AVSEExportCommandCompletionNotification"
    
    var mutableComposition: AVMutableComposition?
    var mutableVideoComposition: AVMutableVideoComposition?
    var mutableAudioMix: AVMutableAudioMix?
    var watermarkLayer: CALayer?
    
    func initWithComposition(_ composition: AVMutableComposition, _ videoComposition: AVMutableVideoComposition, _ audioMix: AVMutableAudioMix) {
        self.mutableComposition = composition
        self.mutableVideoComposition = videoComposition
        self.mutableAudioMix = audioMix
    }
    
    func performWithAsset(_ asset: AVAsset) {
//        self.doesNotRecognizeSelector()
    }
    
    
}
