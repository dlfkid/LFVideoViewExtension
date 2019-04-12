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
    
    var avPlayer: AVPlayer? { get set }
    
    
}

protocol LFVideoPlayerControllerDelegate: UIViewController {
    func videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime)
    func videoPlayerViewReadyToPlay(view: LFVideoPlayerable)
    func videoPlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSError?)
    func videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable)
}

// 需要实现的播放器方法: 1.播放当前URL 2.暂停 3.停止 4.全屏 5.音量 6.静音 7.设置进度
extension LFVideoPlayerable {
    
    var videoURL: URL? {
        return URL(string: videoURLString ?? "")
    }
    
    var isPlaying: Bool {
        guard let player = self.avPlayer else {
            return false
        }
        return player.currentItem != nil && player.rate != 0
    }
    
    var volume: Float {
        get {
            guard let player = self.avPlayer else {
                return 0
            }
            return player.volume
        }
        
        set {
            guard let player = self.avPlayer else {
                return
            }
            if (newValue >= 0 && newValue <= 1 && __inline_isnanf(newValue) == 0) {
                player.volume = newValue
            }
        }
    }
    
    // 装载视频
    func loadCurrentVideo() -> Void {
        guard let player = self.avPlayer else {
            return
        }
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0 / 60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (time) in
            // self?.delegate?.responds(to: #selector()))
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.videoPlayTimeDidChanged(view: strongSelf, time: player.currentTime() )
        }
        
        guard let url: URL = self.videoURL else {
            print("NO avilable URL.");
            return
        }
        
        let videoAssets: AVURLAsset = AVURLAsset(url: url, options: nil)
        let keys = ["playable", "duration"]
        videoAssets.loadValuesAsynchronously(forKeys: keys) {
            let mainQueue = DispatchQueue.main
            mainQueue.sync {
                var error: NSError?
                for key in keys {
                    let assetStatus = videoAssets.statusOfValue(forKey: key, error: &error)
                    guard assetStatus != AVKeyValueStatus.failed else {
                        self.delegate?.videoPlayerViewFailedToPlay(view: self, error: error)
                        return
                    }
                }
                let playerItem = AVPlayerItem(asset: videoAssets)
                player.replaceCurrentItem(with: playerItem)
                let layer = AVPlayerLayer(player: player)
                layer.frame = self.frame
                layer.backgroundColor = UIColor.blue.cgColor
                self.layer.addSublayer(layer)
                self.delegate?.videoPlayerViewReadyToPlay(view: self)
            }
        }
    }
    
    // 播放视频
    func lf_play() {
        guard let player = self.avPlayer else {
            return
        }
        player.play()
    }
    
    // 停止播放视频，进度条归零
    func lf_stop() {
        guard let player = self.avPlayer else {
            return
        }
        player.seek(to: CMTime(value: 0, timescale: CMTimeScale.zero))
        player.pause()
    }
    
    // 暂停
    func lf_pause() {
        guard let player = self.avPlayer else {
            return
        }
        player.pause()
    }
    
    // 调到指定时间
    func lf_seekToTime(time: CMTimeValue) {
        guard let player = self.avPlayer else {
            return
        }
        guard let timeScale = player.currentItem?.asset.duration.timescale else {
            return
        }
        let cmTime: CMTime = CMTime(value: time, timescale: timeScale)
        player.seek(to: cmTime)
    }
    
    func updateVideoOrientation(orientation: UIDeviceOrientation) {
        let layer: AVPlayerLayer = AVPlayerLayer(layer: self.layer);
        layer.videoGravity = orientation.isLandscape ? AVLayerVideoGravity.resize : AVLayerVideoGravity.resizeAspect
    }
}

extension LFVideoPlayerControllerDelegate {
    func videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime) {
        print("Video time: \(time)")
    }
    
    func videoPlayerViewReadyToPlay(view: LFVideoPlayerable) {
        print("Video is ready to play")
    }
    
    func videoPlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSError?) {
        print("Video load is a failure with error \(error?.localizedDescription ?? "Unknown Error")")
    }
    
    func videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable) {
        print("Video play to end time")
    }
}
