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
    func moviePlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime)
    func moviePlayerViewReadyToPlay(view: LFVideoPlayerable)
    func moviePlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSErrorPointer)
}

// 需要实现的播放器方法: 1.播放当前URL 2.暂停 3.停止 4.全屏 5.音量 6.静音 7.设置进度
extension LFVideoPlayerable {
    
    var videoURL: URL? {
        return URL(string: videoURLString ?? "")
    }
    
    private var avPlayer: AVPlayer {
        let player = AVPlayer()
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0 / 60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (time) in
            // self?.delegate?.responds(to: #selector()))
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.moviePlayTimeDidChanged(view: strongSelf, time: strongSelf.avPlayer.currentTime() )
        }
        let layer = AVPlayerLayer(layer: self.layer)
        layer.backgroundColor = self.backgroundColor?.cgColor
        layer.player = player
        
        return player
    }
    
    /*
     
     AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
     NSArray *keys = @[@"playable", @"duration"];
     [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
     IBLRunOnMainThread(^{
     for (NSString *key in keys) {
     NSError *error = nil;
     AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
     
     if (keyStatus == AVKeyValueStatusFailed) {
     if (self.delegate && [self.delegate respondsToSelector:@selector(moviePlayerViewFailedToPlay:error:)]) {
     [self.delegate moviePlayerViewFailedToPlay:self error:error];
     }
     return;
     }
     }
     
     AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
     [self->_player replaceCurrentItemWithPlayerItem:playerItem];
     
     if ([self.delegate respondsToSelector:@selector(moviePlayerViewReadyToPlay:)]) {
     [self.delegate moviePlayerViewReadyToPlay:self];
     }
     
     });
     }];
     
     */
    
    // 播放
    func play() -> Void {
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
                    self.delegate?.moviePlayerViewFailedToPlay(view: self, error: error)
                    return
                }
                let playerItem = AVPlayerItem(asset: videoAssets)
                self.avPlayer.replaceCurrentItem(with: playerItem)
                
                self.delegate?.moviePlayerViewReadyToPlay(view: self)
            }
        }
        
        self.backgroundColor = .black
        
    }
    
    
}
