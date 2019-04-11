//
//  VideoView.swift
//  LFVideoViewExtension
//
//  Created by LeonDeng on 2019/4/11.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

import UIKit
import AVFoundation

class VideoView: UIView, LFVideoPlayerable {
    
    var videoURLString: String?
    
    var delegate: LFVideoPlayerControllerDelegate?
    
    var avPlayer: AVPlayer?
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
}
