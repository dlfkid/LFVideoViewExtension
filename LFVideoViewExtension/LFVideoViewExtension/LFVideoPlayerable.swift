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

// Mark: - 控制器回调

protocol LFVideoPlayerControllerDelegate {
    func lf_videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime)
    func lf_videoPlayerViewReadyToPlay(view: LFVideoPlayerable)
    func lf_videoPlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSError?)
    func lf_videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable)
}

extension LFVideoPlayerControllerDelegate {
    func lf_videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime) {
        print("Video time: \(time)")
    }
    
    func lf_videoPlayerViewReadyToPlay(view: LFVideoPlayerable) {
        print("Video is ready to play")
    }
    
    func lf_videoPlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSError?) {
        print("Video load is a failure with error \(error?.localizedDescription ?? "Unknown Error")")
    }
    
    func lf_videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable) {
        print("Video play to end time")
    }
}

protocol LFVideoPlayerable: UIView {
    
    var videoURLString: String? { get set }
    
    var delegate: LFVideoPlayerControllerDelegate? { get set }
    
    var avPlayer: AVPlayer? { get set }
    
}

// 需要实现的播放器方法: 1.播放当前URL 2.暂停 3.停止 4.全屏 5.音量 6.静音 7.设置进度
extension LFVideoPlayerable {
    
    var lf_videoDuration: Float {
        return Float(CMTimeGetSeconds(self.avPlayer?.currentItem?.asset.duration ?? CMTime(value: 0, timescale: 1)))
    }
    
    var lf_videoURL: URL? {
        return URL(string: videoURLString ?? "")
    }
    
    var lf_isPlaying: Bool {
        guard let player = self.avPlayer else {
            return false
        }
        return player.currentItem != nil && player.rate != 0
    }
    
    var lf_volume: Float {
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
    
    func lf_playVideo(videoURLString: String) {
        self.avPlayer = AVPlayer()
        let videoURL = URL(string: videoURLString)
        self.lf_loadVideo(url: videoURL) {
            self.lf_play()
        }
    }
    
    // 装载视频
    func lf_loadVideo(url: URL?, completion: (_: () -> Void)?) -> Void {
        guard let player = self.avPlayer else {
            return
        }
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0 / 60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (time) in
            // self?.delegate?.responds(to: #selector()))
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.lf_videoPlayTimeDidChanged(view: strongSelf, time: player.currentTime() )
        }
        
        guard let videoURL = url else {
            print("URL is unavailable")
            return
        }
        
        let videoAssets: AVURLAsset = AVURLAsset(url: videoURL, options: nil)
        let keys = ["playable", "duration"]
        videoAssets.loadValuesAsynchronously(forKeys: keys) {
            let mainQueue = DispatchQueue.main
            mainQueue.sync {
                var error: NSError?
                for key in keys {
                    let assetStatus = videoAssets.statusOfValue(forKey: key, error: &error)
                    guard assetStatus != AVKeyValueStatus.failed else {
                        self.delegate?.lf_videoPlayerViewFailedToPlay(view: self, error: error)
                        return
                    }
                }
                let playerItem = AVPlayerItem(asset: videoAssets)
                player.replaceCurrentItem(with: playerItem)
                let layer = AVPlayerLayer(player: player)
                layer.frame = self.frame
                layer.backgroundColor = UIColor.blue.cgColor
                self.layer.addSublayer(layer)
                self.delegate?.lf_videoPlayerViewReadyToPlay(view: self)
                guard let handler = completion else {
                    return
                }
                handler()
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
        player.seek(to: CMTime(value: 0, timescale: 1))
        player.pause()
    }
    
    // 暂停
    func lf_pause() {
        guard let player = self.avPlayer else {
            return
        }
        player.pause()
    }
    
    // 声音开关
    func lf_speaker(state: Bool) {
        guard let player = self.avPlayer else {
            return
        }
        player.isMuted = !state
    }
    
    // 调到指定时间值
    func lf_seekTo(timeValue: CMTimeValue) {
        guard let player = self.avPlayer else {
            return
        }
        guard let timeScale = player.currentItem?.asset.duration.timescale else {
            return
        }
        let cmTime: CMTime = CMTime(value: timeValue, timescale: timeScale)
        player.seek(to: cmTime)
    }
    
    // 调到指定时间
    func lf_seekTo(time: CMTime) {
        guard let player = self.avPlayer else {
            return
        }
        player.seek(to: time)
    }
    
    // 调到指定进度
    func lf_seekTo(percentage: Float) {
        guard let player = self.avPlayer else {
            return
        }
        
        var tempPercent = percentage
        if percentage < 0 {
            tempPercent = 0;
        }
        if percentage > 1 {
            tempPercent = 1;
        }
        
        let totalTimeValue: Int64 = player.currentItem?.asset.duration.value ?? 0
        let targetTimeValue = Float(totalTimeValue) * tempPercent
        self.lf_seekTo(timeValue: CMTimeValue(targetTimeValue))
    }
    
    func lf_updateVideoOrientation(orientation: UIDeviceOrientation) {
        let layer: AVPlayerLayer = AVPlayerLayer(layer: self.layer);
        layer.videoGravity = orientation.isLandscape ? AVLayerVideoGravity.resize : AVLayerVideoGravity.resizeAspect
    }
}
