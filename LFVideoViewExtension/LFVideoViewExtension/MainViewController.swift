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

class MainViewController: UIViewController {

    let videoView = VideoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200))
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    let playButton = UIButton(type: .custom)
    let stopButton = UIButton(type: .custom)
    let speakerButton = UIButton(type: .custom)
    
    let progressView = UISlider(frame: .zero)
    
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
        
        playButton.setTitle("Play", for: .normal)
        playButton.setTitle("Pause", for: .selected)
        playButton.setTitleColor(.black, for: .normal)
        playButton.backgroundColor = .yellow
        playButton.frame = CGRect(x: 50, y: 210, width: 100, height: 44)
        playButton.addTarget(self, action: #selector(playButtonDidTappedAction), for: .touchUpInside)
        view.addSubview(playButton)
        
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.black, for: .normal)
        stopButton.backgroundColor = .cyan
        stopButton.frame = CGRect(x: 160, y: 210, width: 100, height: 44)
        stopButton.addTarget(self, action: #selector(stopButtonDidTappedAction), for: .touchUpInside)
        view.addSubview(stopButton)
        
        speakerButton.setTitle("SpeakerOff", for: .normal)
        speakerButton.setTitle("SpeakerOn", for: .selected)
        speakerButton.setTitleColor(.black, for: .normal)
        speakerButton.backgroundColor = .green
        speakerButton.frame = CGRect(x: 270, y: 210, width: 100, height: 44)
        speakerButton.addTarget(self, action: #selector(speakerButtonDidTappedAction), for: .touchUpInside)
        view.addSubview(speakerButton)
        
        progressView.frame = CGRect(x: 50, y: 260, width: screenWidth - 100, height: 30)
        progressView.addTarget(self, action: #selector(progressViewValueChangedAction), for: .valueChanged)
        progressView.minimumValue = 0
        view.addSubview(progressView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func playButtonDidTappedAction() {
        if playButton.isSelected {
            videoView.lf_pause()
        } else {
            videoView.lf_play()
        }
        self.playButton.isSelected = !self.playButton.isSelected
    }
    
    @objc func stopButtonDidTappedAction() {
        videoView.lf_stop()
        self.playButton.isSelected = false
    }
    
    @objc func speakerButtonDidTappedAction() {
        videoView.lf_speaker(state: self.speakerButton.isSelected)
        self.speakerButton.isSelected = !self.speakerButton.isSelected
    }
    
    @objc func progressViewValueChangedAction() {
        
    }
}

extension MainViewController: LFVideoPlayerControllerDelegate {
    func videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable) {
        self.playButton.isSelected = false
    }
    
    func videoPlayerViewReadyToPlay(view: LFVideoPlayerable) {
        view.lf_play()
        view.lf_seekTo(percentage: 0.7)
    }
    
    func videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime) {
        self.progressView.value = Float(time.value)
    }
}
