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

class AudioPlayer: UIViewController{
    
    var audioTitle = ""
    var audioUrlString = ""
    var audioId = ""
    var player = AVPlayer()
    
    @IBAction func ButtonPlayPause(_ sender: UIBarButtonItem) {
        audioUrlString = "https://creatives.ftimg.net/album/20170405050224-2-128.mp3"
        print (audioUrlString)
        if let url = URL(string: audioUrlString) {
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            //let player = AVPlayer(playerItem: playerItem)
            player.replaceCurrentItem(with: playerItem)
            player.rate = 1.0
            player.play()
//            if #available(iOS 10.0, *) {
//                player.playImmediately(atRate: 1.0)
//            } else {
//                player.play()
//            }
        }
        
    }
    
    @IBAction func StopAudio(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func loadView() {
        super.loadView()
        parseAudioMessage()
    }
    
    private func parseAudioMessage() {
        let body = AudioContent.sharedInstance.body
        print (body)
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            print (title)
            audioTitle = title
            audioUrlString = audioFileUrl
            audioId = interactiveUrl
            print (audioUrlString)
        }
    }
}
