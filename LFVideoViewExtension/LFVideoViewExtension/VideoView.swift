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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishedPlayToEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFailedPlayToEnd(notify:)), name: Notification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoView {
    @objc func videoDidFinishedPlayToEnd() {
        self.lf_stop()
        print("Video play finished");
        self.delegate?.lf_videoPlayerViewDidPlayToEndTime(view: self)
    }
    
    @objc func videoDidFailedPlayToEnd(notify: Notification) {
        guard let notifyError: NSError = notify.object as? NSError else {
            return
        }
        print("Video failed to play with error: \(notifyError.localizedDescription)")
        self.delegate?.lf_videoPlayerViewFailedToPlay(view: self, error: notifyError)
    }
}
