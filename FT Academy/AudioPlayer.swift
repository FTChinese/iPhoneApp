//
//  AudioPlayer.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/5.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer


// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.
class AudioContent {
    static let sharedInstance = AudioContent()
    var body = [String: String]()
}

class AudioPlayer: UIViewController {
    
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var buttonPlayAndPause: UIBarButtonItem!
    @IBOutlet weak var progressSlider: UISlider!
    @IBAction func ButtonPlayPause(_ sender: UIBarButtonItem) {
        if let player = player {
            print(player.rate)
            if (player.rate != 0) && (player.error == nil) {
                print ("should pause audio")
                player.pause()
                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            } else {
                print ("should play audio")
                player.play()
                player.replaceCurrentItem(with: playerItem)
                buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            }
        }
    }
    
    @IBAction func StopAudio(_ sender: UIBarButtonItem) {
        if let player = player {
            player.pause()
            self.player = nil
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        //let maxTime = sender.maximumValue
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        playerItem?.seek(to: currentTime)
        
        //print ("seeking to: \(currentTime)")
    }
    
    override func loadView() {
        super.loadView()
        parseAudioMessage()
        prepareAudioPlay()
    }
    
    private func parseAudioMessage() {
        let body = AudioContent.sharedInstance.body
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            print (title)
            audioTitle = title
            audioUrlString = audioFileUrl
            audioId = interactiveUrl
        }
    }
    
    private func prepareAudioPlay() {
        
        // MARK: - Use https url so that the audio can be buffered properly on actual devices
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://creatives.ftimg.net/album/")
        
        // MARK: - Remove toolBar's top border. This cannot be done in interface builder.
        toolBar.clipsToBounds = true
        
        if let url = URL(string: audioUrlString) {
            let asset = AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer()
            //player?.rate = 1.0
            //player?.play()
            
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { time in
                if let d = self.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        self.progressSlider.maximumValue = Float(duration)
                        if self.progressSlider.isHighlighted == false {
                            self.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                    }
                }
            }
            
            // MARK: - Observe Play to the End
            NotificationCenter.default.addObserver(self,selector:#selector(AudioPlayer.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            
            
            
            //player?.actionAtItemEnd = .pause
            
            // MARK: - Update buffer status
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        }
    }
    
    func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing")
                    
                case "playbackBufferFull":
                    // Hide loader
                    print ("load successfully")
                default:
                    break
                }
            }
            
        }
    }
    
    // TODO: Share
    
    // TODO: Download Management: Download or Delete
    
    // TODO: Subscribe
    
    // TODO: Display Background Images for Radio Columns
    
    // TODO: Display the audio text
    
    // MARK: - Done: Update play progress
    
    
}
