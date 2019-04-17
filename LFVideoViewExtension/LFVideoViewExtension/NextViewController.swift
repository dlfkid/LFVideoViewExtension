//
//  NextViewController.swift
//  LFVideoViewExtension
//
//  Created by LeonDeng on 2019/4/17.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

import UIKit
import AVFoundation

class NextViewController: UIViewController {

    let screenWidth = UIScreen.main.bounds.size.width
    
    var testView: LFVideoPlayerable
    
    init() {
        testView = VideoView(frame: CGRect(x: 0, y: 100, width: screenWidth, height: 200))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Next"
        view.addSubview(testView)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        testView.lf_playVideo(videoURLString: GlobalConstants.kSampleVideoURL)
    }
}
