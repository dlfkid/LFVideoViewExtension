# LFVideoViewExtension

Simple video player encapsulation based on AVFoundation, easy to use, highly customizable.

## How to use

### Default View
1. Create a LFVideoView instance and layout it in the controller's view. Than call lf_playVideo method.

```swift
// Play the video right after it's loaded
testView.lf_playVideo(videoURLString:"http://www.w3school.com.cn/example/html5/mov_bbb.mp4")
```

2. Feel free to monitor or control the player view's behavior with methods below
```swift
// Load video 
func lf_loadVideo(url: URL?, completion: (_: () -> Void)?) -> Void

// Play current loaded video
func lf_play()

// Pause
func lf_pause()

// Stop the video and set progress to start
func lf_stop()

// Set speaker muted or not
lf_speaker(state: Bool)

// Getter & Setter of Volume
lf_volume

// Return if the video is playing
lf_isPlaying

// Duration of current loaded video
lf_videoDuration

// Set progress of the video
func lf_seekTo(time: CMTime)
func lf_seekTo(timeValue: CMTimeValue)
func lf_seekTo(percentage: Float)

// Set orientation of the video output
func lf_updateVideoOrientation(orientation: UIDeviceOrientation)
```

3. Use call backs after set your videoView's delegate 
```swift
func lf_videoPlayTimeDidChanged(view: LFVideoPlayerable, time: CMTime)
func lf_videoPlayerViewReadyToPlay(view: LFVideoPlayerable)
func lf_videoPlayerViewFailedToPlay(view: LFVideoPlayerable, error: NSError?)
func lf_videoPlayerViewDidPlayToEndTime(view: LFVideoPlayerable)
```

### Customize View
1.  Design an class that is subclass to UIView and make sure to implement these protocol properties and methods
```swift
var videoURLString: String?

var delegate: LFVideoPlayerControllerDelegate?

var avPlayer: AVPlayer?
```

2.  AVPlayer will post these notification when triggered, sorry I have no idea how to encapsulate them into protocols, so you must observer them manually, they are
```swift
Notification.Name.AVPlayerItemDidPlayToEndTime
Notification.Name.AVPlayerItemFailedToPlayToEndTime
```

3. For more informations, just look into the source code where LFVideoView class is implemented

### solicit criticisms

Any idea how I can make it more easier to use or make the code be more elegant are welcome!
