//
//  MainViewController.swift
//  LFVideoViewExtension
//
//  Created by LeonDeng on 2019/4/10.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {

    let videoView = LFVideoView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200))
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    let playButton = UIButton(type: .custom)
    let stopButton = UIButton(type: .custom)
    let speakerButton = UIButton(type: .custom)
    
    let progressView = UISlider(frame: .zero)
    let volumeSlider = UISlider(frame: .zero)
    
    var isDragging: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Demo"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(gotoNextController))
        
        view.addSubview(videoView)
        videoView.backgroundColor = .cyan
        videoView.avPlayer = AVPlayer()
        videoView.delegate = self;
        
        playButton.setTitle("Play", for: .normal)
        playButton.setTitle("Pause", for: .selected)
        playButton.setTitleColor(.black, for: .normal)
        playButton.backgroundColor = .yellow
        playButton.frame = CGRect(x: 50, y: 210, width: 100, height: 44)
        playButton.addTarget(self, action: #selector(playButtonDidTappedAction), for: .touchUpInside)
        playButton.isEnabled = false
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
        
        progressView.frame = CGRect(x: 50, y: 260, width: screenWidth - 100, height: 10)
        progressView.isContinuous = false
        progressView.addTarget(self, action: #selector(progressViewValueChangedAction(event:)), for: .valueChanged)
        progressView.minimumValue = 0
        view.addSubview(progressView)
        
        volumeSlider.frame = CGRect(x: 50, y: 300, width: screenWidth - 100, height: 10)
        volumeSlider.maximumValue = 100
        volumeSlider.minimumValue = 0
        volumeSlider.addTarget(self, action: #selector(volumeSliderValueChangedAction(event:)), for: .valueChanged)
        view.addSubview(volumeSlider)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let videoURL = URL(string: GlobalConstants.kSampleVideoURL)
        self.videoView.lf_loadVideo(url: videoURL, completion: nil)
    }
    
    @objc func playButtonDidTappedAction() {
        if playButton.isSelected {
            videoView.lf_pause()
        } else {
            videoView.lf_play()
        }
        self.playButton.isSelected = !self.playButton.isSelected
        volumeSlider.value = videoView.lf_volume * 100
    }
    
    @objc func stopButtonDidTappedAction() {
        videoView.lf_stop()
        self.playButton.isSelected = false
    }
    
    @objc func speakerButtonDidTappedAction() {
        videoView.lf_speaker(state: self.speakerButton.isSelected)
        self.speakerButton.isSelected = !self.speakerButton.isSelected
    }
    
    @objc func progressViewValueChangedAction(event: UIEvent) {
        guard (videoView.avPlayer?.currentItem?.asset) != nil else {
            return
        }
//        let time = CMTime(seconds: Double(progressView.value), preferredTimescale: timeScale)
//        videoView.lf_seekTo(time: time)
        let percentage = progressView.value / progressView.maximumValue;
        videoView.lf_seekTo(percentage: percentage)
    }
    
    @objc func volumeSliderValueChangedAction(event: UIEvent) {
        videoView.lf_volume = volumeSlider.value * 0.01
    }
    
    @objc func gotoNextController() {
        self.navigationController?.pushViewController(NextViewController(), animated: true)
    }
}

extension MainViewController: LFVideoPlayerControllerDelegate {
    func lf_videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable) {
        self.playButton.isSelected = false
    }
    
    func lf_videoPlayerViewReadyToPlay(view: LFVideoPlayerable) {
        playButton.isEnabled = true;
        progressView.maximumValue = videoView.lf_videoDuration
    }
    
    func lf_videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime) {
        if (!progressView.isHighlighted) {
            progressView.value = Float(time.seconds)
        }
    }
}
