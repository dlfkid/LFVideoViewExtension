//
//  LFVideoPlayer.swift
//  LFVideoViewExtension
//
//  Created by LeonDeng on 2019/4/10.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol LFVideoPlayerable: UIView {
    
    var videoURLString: String? { get set }
    
    var delegate: LFVideoPlayerControllerDelegate? { get set }
}

protocol LFVideoPlayerControllerDelegate: UIViewController {
    func videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime)
    func videoPlayerViewReadyToPlay(view: LFVideoPlayerable)
    func videoPlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSErrorPointer)
}

// 需要实现的播放器方法: 1.播放当前URL 2.暂停 3.停止 4.全屏 5.音量 6.静音 7.设置进度
extension LFVideoPlayerable {
    
    var videoURL: URL? {
        return URL(string: videoURLString ?? "")
    }
    
    var isPlaying: Bool {
        return self.avPlayer.currentItem != nil && self.avPlayer.rate != 0
    }
    
    var volume: Float {
        get {
            return self.avPlayer.volume
        }
        
        set {
            if (newValue >= 0 && newValue <= 1 && __inline_isnanf(newValue) == 0) {
                self.avPlayer.volume = newValue
            }
        }
    }
    
    private var avPlayer: AVPlayer {
        let player = AVPlayer()
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0 / 60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (time) in
            // self?.delegate?.responds(to: #selector()))
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.videoPlayTimeDidChanged(view: strongSelf, time: strongSelf.avPlayer.currentTime() )
        }
        let layer = AVPlayerLayer(layer: self.layer)
        layer.backgroundColor = self.backgroundColor?.cgColor
        layer.player = player
        
        return player
    }
    
    // 装载视频
    func loadCurrentVideo() -> Void {
        guard let url: URL = self.videoURL else {
            print("NO avilable URL.");
            return
        }
        
        let videoAssets: AVURLAsset = AVURLAsset(url: url, options: nil)
        let keys = ["playable", "duration"]
        videoAssets.loadValuesAsynchronously(forKeys: keys) {
            let error: NSErrorPointer = nil
            for key in keys {
                let assetStatus = videoAssets.statusOfValue(forKey: key, error: error)
                guard assetStatus != AVKeyValueStatus.failed else {
                    self.delegate?.videoPlayerViewFailedToPlay(view: self, error: error)
                    return
                }
                let playerItem = AVPlayerItem(asset: videoAssets)
                self.avPlayer.replaceCurrentItem(with: playerItem)
                
                self.delegate?.videoPlayerViewReadyToPlay(view: self)
            }
        }
        
        self.backgroundColor = .black
        
    }
    
    // 播放视频
    func lf_play() {
        self.avPlayer.play()
    }
    
    // 停止播放视频，进度条归零
    func lf_stop() {
        self.avPlayer.seek(to: CMTime(value: 0, timescale: CMTimeScale.zero))
        self.avPlayer.pause()
    }
    
    // 暂停
    func lf_pause() {
        self.avPlayer.pause()
    }
    
    // 调到指定时间
    func lf_seekToTime(time: CMTimeValue) {
        guard let timeScale = self.avPlayer.currentItem?.asset.duration.timescale else {
            return
        }
        let cmTime: CMTime = CMTime(value: time, timescale: timeScale)
        self.avPlayer.seek(to: cmTime)
    }
    
    
}
