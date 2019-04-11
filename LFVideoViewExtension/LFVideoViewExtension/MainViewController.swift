//
//  MainViewController.swift
//  LFVideoViewExtension
//
//  Created by LeonDeng on 2019/4/10.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

import UIKit
import AVFoundation

let kSampleVideoURL: String = "http://www.w3school.com.cn/example/html5/mov_bbb.mp4"

class MainViewController: UIViewController, LFVideoPlayerControllerDelegate {

    let videoView = VideoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200))
    
    let button = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Demo"
        
        view.addSubview(videoView)
        videoView.backgroundColor = .cyan
        videoView.avPlayer = AVPlayer()
        videoView.videoURLString = kSampleVideoURL
        videoView.delegate = self;
        videoView.loadCurrentVideo()
        
        button.setTitle("播放视频", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.frame = CGRect(x: 50, y: 210, width: 100, height: 44)
        button.addTarget(self, action: #selector(playButtonDidTappedAction), for: .touchUpInside)
        view.addSubview(button)
    }
    
    
    @objc func playButtonDidTappedAction() {
        videoView.lf_play()
    }
}
